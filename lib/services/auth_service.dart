import 'dart:io'; // Для Platform
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';
import 'package:fastable/injection.dart'; // Для getIt

// Репозитории (для миграции данных)
import 'package:fastable/repositories/weight_repository.dart';
import 'package:fastable/repositories/history_repository.dart';
import 'package:fastable/repositories/water_repository.dart';

/// 🚨 Исключение для конфликта данных (показываем диалог пользователю)
class DataConflictException implements Exception {
  final String message;
  DataConflictException(this.message);
}

@lazySingleton
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Стрим состояния (слушаем в main.dart для роутинга)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Текущий юзер
  User? get currentUser => _auth.currentUser;

  // ===========================================================================
  // 1. АНОНИМНЫЙ ВХОД (Android & iOS)
  // ===========================================================================
  Future<User?> signInAnonymously() async {
    try {
      final result = await _auth.signInAnonymously();
      debugPrint("👻 Signed in anonymously: ${result.user?.uid}");
      return result.user;
    } catch (e) {
      debugPrint("❌ Anonymous sign in error: $e");
      return null;
    }
  }

  // ===========================================================================
  // 2. GOOGLE SIGN IN (Android & iOS)
  // ===========================================================================
  Future<User?> signInWithGoogle() async {
    try {
      // Запускаем нативный флоу Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // Пользователь нажал "Отмена" в окне Google
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _signInOrLink(credential);
    } catch (e) {
      // Если это наш DataConflictException, пробрасываем выше (в UI)
      if (e is DataConflictException) rethrow;

      debugPrint("❌ Google Sign In Error: $e");
      throw Exception("Google Sign In Failed");
    }
  }

  // ===========================================================================
  // 3. APPLE SIGN IN (Только iOS)
  // ===========================================================================
  Future<User?> signInWithApple() async {
    if (!Platform.isIOS) {
      throw Exception("Apple Sign In is only available on iOS");
    }

    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      );

      final AuthCredential credential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      return await _signInOrLink(credential);
    } catch (e) {
      if (e is DataConflictException) rethrow;

      debugPrint("❌ Apple Sign In Error: $e");

      // 🔥 ИСПРАВЛЕНИЕ 2: Безопасная проверка ошибки отмены Apple Sign In (Типизация вместо подстроки)
      if (e is SignInWithAppleAuthorizationException) {
        if (e.code == AuthorizationErrorCode.canceled) {
          return null;
        }
      }

      throw Exception("Apple Sign In Failed");
    }
  }

  // ===========================================================================
  // 🧠 ГЛАВНАЯ ЛОГИКА (ВХОД / LINK / МИГРАЦИЯ)
  // ===========================================================================
  Future<User?> _signInOrLink(AuthCredential credential) async {
    User? user = _auth.currentUser;
    // Запоминаем, были ли мы анонимом (до попытки входа)
    bool wasAnonymous = user?.isAnonymous ?? false;

    // 🔥 ИСПРАВЛЕНИЕ 1: Сохраняем старый UID анонима до того, как Firebase его затрет
    String? oldUid = user?.uid;

    try {
      if (wasAnonymous) {
        // СЦЕНАРИЙ А: Мы Аноним -> Пытаемся ПРИВЯЗАТЬ (Link) Google/Apple
        final result = await user!.linkWithCredential(credential);
        user = result.user;

        // На всякий случай запускаем миграцию, чтобы убедиться, что локальные данные в облаке
        if (user != null) {
          await _migrateAllData(user.uid); // Здесь можно передать oldUid в будущем, если репозитории будут его требовать
        }
      } else {
        // СЦЕНАРИЙ Б: Мы не в системе -> Просто входим
        final result = await _auth.signInWithCredential(credential);
        user = result.user;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        // СЦЕНАРИЙ В: Такой Google/Apple уже привязан к ДРУГОМУ аккаунту.
        debugPrint("⚠️ Account exists. Switching users...");

        // 1. Входим в старый аккаунт (Анонимный UID при этом сбрасывается, но мы сохранили oldUid!)
        final result = await _auth.signInWithCredential(credential);
        user = result.user;

        // 2. 🛑 ПРОВЕРКА НА КОНФЛИКТ
        if (user != null && wasAnonymous && oldUid != null) {
          final weightRepo = getIt<WeightRepository>();
          // Используем oldUid для проверки локальных данных, если репо это поддерживает,
          // либо просто проверяем наличие несохраненных данных на девайсе
          final hasLocal = await weightRepo.hasLocalData();
          final hasCloud = await weightRepo.hasCloudData(user.uid);

          if (hasLocal && hasCloud) {
            // 💣 КОНФЛИКТ! Бросаем исключение, UI покажет диалог "Merge vs Discard"
            throw DataConflictException("Conflict Detected");
          } else if (hasLocal) {
            // В облаке пусто -> Просто заливаем наши локальные данные туда
            await _migrateAllData(user.uid);
          }
        }
      } else {
        rethrow;
      }
    }
    return user;
  }

  // ===========================================================================
  // 🛠 РАЗРЕШЕНИЕ КОНФЛИКТА (Вызывается из UI диалога)
  // ===========================================================================
  Future<void> resolveDataConflict({required bool mergeData}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (mergeData) {
      // Вариант А: Объединить (Локальные + Облачные)
      await _migrateAllData(user.uid);
    } else {
      // Вариант Б: Использовать облако (Удалить локальные данные гостя)
      await getIt<WeightRepository>().discardLocalAndUseCloud(user.uid);
      await getIt<HistoryRepository>().getAllRecords();
      await getIt<WaterRepository>().getHistory();
    }
  }

  // --- ХЕЛПЕР: Массовая миграция всех репозиториев ---
  Future<void> _migrateAllData(String uid) async {
    debugPrint("🚀 Migrating ALL data to cloud for user $uid...");

    await Future.wait([
      getIt<WeightRepository>().migrateLocalToCloud(uid),
      getIt<HistoryRepository>().migrateLocalToCloud(uid),
      getIt<WaterRepository>().migrateLocalToCloud(uid),
    ]);

    debugPrint("✅ Full migration complete");
  }

  // ===========================================================================
  // 4. ВЫХОД
  // ===========================================================================
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      debugPrint("👋 Signed out");
    } catch (e) {
      debugPrint("❌ Sign out error: $e");
    }
  }

  // ===========================================================================
  // 5. УДАЛЕНИЕ АККАУНТА (GDPR / Apple Requirement)
  // ===========================================================================
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      debugPrint("🗑 Deleting account and all data...");

      // 1. Чистим данные во всех репозиториях (Локально + Firestore)
      await Future.wait([
        getIt<WeightRepository>().clearAllData(),
        getIt<HistoryRepository>().clearAllData(),
        getIt<WaterRepository>().clearAllData(),
      ]);

      // 2. Удаляем самого пользователя из Auth
      await user.delete();

      debugPrint("✅ Account deleted successfully");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        // Мера безопасности Firebase: если сессия старая, нужно перелогиниться
        debugPrint("⚠️ Re-login required for account deletion");
        throw Exception('requires-recent-login');
      }
      rethrow;
    } catch (e) {
      debugPrint("❌ Delete account error: $e");
      throw Exception("Failed to delete account");
    }
  }
}