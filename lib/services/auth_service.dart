import 'dart:io'; // Для Platform
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fastable/injection.dart'; // Для getIt
import 'package:fastable/l10n/app_localizations.dart';

// Репозитории (для миграции данных)
import 'package:fastable/repositories/weight_repository.dart';
import 'package:fastable/repositories/history_repository.dart';
import 'package:fastable/repositories/water_repository.dart';
import 'package:fastable/services/live_activity_services.dart';
import 'package:fastable/services/notification_service.dart';
import 'package:fastable/utils/user_session_preferences.dart';

/// 🚨 Исключение для конфликта данных (показываем диалог пользователю)
class DataConflictException implements Exception {
  final String message;
  DataConflictException(this.message);
}

enum AuthFlowError {
  googleSignInFailed,
  appleSignInUnavailable,
  appleSignInFailed,
}

class AuthFlowException implements Exception {
  final AuthFlowError error;

  const AuthFlowException(this.error);
}

enum AccountDeletionError {
  reauthenticationCancelled,
  reauthenticationFailed,
  reauthenticationUnavailable,
  deleteFailed,
}

class AccountDeletionException implements Exception {
  final AccountDeletionError error;

  const AccountDeletionException(this.error);
}

@lazySingleton
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Future<User?>? _anonymousSignInFuture;

  // Стрим состояния (слушаем в main.dart для роутинга)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Текущий юзер
  User? get currentUser => _auth.currentUser;

  // ===========================================================================
  // 1. АНОНИМНЫЙ ВХОД (Android & iOS)
  // ===========================================================================
  Future<User?> signInAnonymously() async {
    final existingUser = _auth.currentUser;
    if (existingUser != null) {
      return existingUser;
    }

    if (_anonymousSignInFuture != null) {
      return _anonymousSignInFuture;
    }

    try {
      _anonymousSignInFuture = _auth
          .signInAnonymously()
          .then((result) {
            debugPrint("👻 Signed in anonymously: ${result.user?.uid}");
            return result.user;
          })
          .catchError((Object error, StackTrace stackTrace) {
            debugPrint("❌ Anonymous sign in error: $error");
            return null;
          })
          .whenComplete(() {
            _anonymousSignInFuture = null;
          });

      return await _anonymousSignInFuture;
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

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _signInOrLink(credential);
    } catch (e) {
      // Если это наш DataConflictException, пробрасываем выше (в UI)
      if (e is DataConflictException) rethrow;

      debugPrint("❌ Google Sign In Error: $e");
      throw const AuthFlowException(AuthFlowError.googleSignInFailed);
    }
  }

  // ===========================================================================
  // 3. APPLE SIGN IN (Только iOS)
  // ===========================================================================
  Future<User?> signInWithApple() async {
    if (!Platform.isIOS) {
      throw const AuthFlowException(AuthFlowError.appleSignInUnavailable);
    }

    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
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

      throw const AuthFlowException(AuthFlowError.appleSignInFailed);
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

    if (!wasAnonymous && oldUid != null) {
      await UserSessionPreferences.mergeCurrentIntoUser(oldUid);
    }

    try {
      if (wasAnonymous) {
        // СЦЕНАРИЙ А: Мы Аноним -> Пытаемся ПРИВЯЗАТЬ (Link) Google/Apple
        final result = await user!.linkWithCredential(credential);
        user = result.user;

        // На всякий случай запускаем миграцию, чтобы убедиться, что локальные данные в облаке
        if (user != null) {
          await _migrateAllData(
            user.uid,
          ); // Здесь можно передать oldUid в будущем, если репозитории будут его требовать
          await _promoteCurrentSessionToUser(user.uid);
        }
      } else {
        // СЦЕНАРИЙ Б: Мы не в системе -> Просто входим
        final result = await _auth.signInWithCredential(credential);
        user = result.user;
        if (user != null && user.uid != oldUid) {
          await _restoreUserSession(user.uid);
        }
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
          final historyRepo = getIt<HistoryRepository>();
          final waterRepo = getIt<WaterRepository>();

          final hasLocal = (await Future.wait([
            weightRepo.hasLocalData(),
            historyRepo.hasLocalData(),
            waterRepo.hasLocalData(),
          ])).any((value) => value);

          final hasCloud = (await Future.wait([
            weightRepo.hasCloudData(user.uid),
            historyRepo.hasCloudData(user.uid),
            waterRepo.hasCloudData(user.uid),
          ])).any((value) => value);

          if (hasLocal && hasCloud) {
            // 💣 КОНФЛИКТ! Бросаем исключение, UI покажет диалог "Merge vs Discard"
            throw DataConflictException("Conflict Detected");
          } else if (hasLocal) {
            // В облаке пусто -> Просто заливаем наши локальные данные туда
            await _migrateAllData(user.uid);
            await _promoteCurrentSessionToUser(user.uid);
          } else {
            await _restoreUserSession(user.uid);
          }
        } else if (user != null && user.uid != oldUid) {
          await _restoreUserSession(user.uid);
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
      await _promoteCurrentSessionToUser(user.uid);
    } else {
      // Вариант Б: Использовать облако (Удалить локальные данные гостя)
      await Future.wait([
        getIt<WeightRepository>().discardLocalAndUseCloud(user.uid),
        getIt<HistoryRepository>().discardLocalAndUseCloud(user.uid),
        getIt<WaterRepository>().discardLocalAndUseCloud(user.uid),
      ]);
      await _restoreUserSession(user.uid);
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
  // 🔥 ИСПРАВЛЕНИЕ: Очищаем локальные данные при выходе, чтобы не слить их другому юзеру!
  Future<void> signOut() async {
    try {
      debugPrint("👋 Signing out and clearing local cache...");

      final user = _auth.currentUser;
      if (user != null && !user.isAnonymous) {
        await UserSessionPreferences.mergeCurrentIntoUser(user.uid);
      }

      await _clearCurrentSessionData();

      // Очищаем кэши репозиториев перед выходом из Firebase
      await Future.wait([
        getIt<WeightRepository>().clearLocalCache(),
        getIt<HistoryRepository>().clearLocalCache(),
        getIt<WaterRepository>().clearLocalCache(),
      ]);

      await _googleSignIn.signOut();
      await _auth.signOut();
      _anonymousSignInFuture = null;
      debugPrint("✅ Signed out successfully");
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

      if (!user.isAnonymous) {
        await _reauthenticateForAccountDeletion(user);
      }

      final activeUser = _auth.currentUser;
      if (activeUser == null) {
        throw const AccountDeletionException(AccountDeletionError.deleteFailed);
      }

      final uid = activeUser.uid;

      await _clearCurrentSessionData();
      await UserSessionPreferences.deleteSnapshotFor(uid);

      // 1. Чистим данные во всех репозиториях (Локально + Firestore)
      await Future.wait([
        getIt<WeightRepository>().clearAllData(),
        getIt<HistoryRepository>().clearAllData(),
        getIt<WaterRepository>().clearAllData(),
      ]);

      // 2. Удаляем самого пользователя из Auth
      await activeUser.delete();
      _anonymousSignInFuture = null;

      debugPrint("✅ Account deleted successfully");
    } on AccountDeletionException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      debugPrint("❌ Delete account auth error: ${e.code}");
      throw const AccountDeletionException(AccountDeletionError.deleteFailed);
    } catch (e) {
      debugPrint("❌ Delete account error: $e");
      throw const AccountDeletionException(AccountDeletionError.deleteFailed);
    }
  }

  Future<void> _promoteCurrentSessionToUser(String uid) async {
    await UserSessionPreferences.mergeCurrentIntoUser(uid);
    await _restoreUserSession(uid);
  }

  Future<void> _restoreUserSession(String uid) async {
    await _resetSessionSideEffects();
    await UserSessionPreferences.restoreForUser(uid);
    await _rescheduleNotifications();
  }

  Future<void> _clearCurrentSessionData() async {
    await _resetSessionSideEffects();
    await UserSessionPreferences.clearCurrentSessionData();
  }

  Future<void> _resetSessionSideEffects() async {
    await Future.wait([
      getIt<NotificationService>().cancelAllNotifications(),
      getIt<LiveActivityService>().stopActivity(),
    ]);
  }

  Future<void> _rescheduleNotifications() async {
    final l10n = await _loadAppLocalizations();
    await getIt<NotificationService>().rescheduleAll(l10n);
  }

  Future<AppLocalizations> _loadAppLocalizations() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString('locale_code') ?? 'en';
    return lookupAppLocalizations(Locale(localeCode));
  }

  Future<void> _reauthenticateForAccountDeletion(User user) async {
    final providerIds = user.providerData.map(
      (provider) => provider.providerId,
    );

    if (providerIds.contains(GoogleAuthProvider.PROVIDER_ID)) {
      await _reauthenticateWithGoogle(user);
      return;
    }

    if (providerIds.contains('apple.com')) {
      await _reauthenticateWithApple(user);
      return;
    }

    throw const AccountDeletionException(
      AccountDeletionError.reauthenticationUnavailable,
    );
  }

  Future<void> _reauthenticateWithGoogle(User user) async {
    try {
      await _googleSignIn.signOut();
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AccountDeletionException(
          AccountDeletionError.reauthenticationCancelled,
        );
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await user.reauthenticateWithCredential(credential);
    } on AccountDeletionException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      debugPrint("❌ Google reauth error: ${e.code}");
      throw const AccountDeletionException(
        AccountDeletionError.reauthenticationFailed,
      );
    } catch (e) {
      debugPrint("❌ Google reauth error: $e");
      throw const AccountDeletionException(
        AccountDeletionError.reauthenticationFailed,
      );
    }
  }

  Future<void> _reauthenticateWithApple(User user) async {
    if (!Platform.isIOS) {
      throw const AccountDeletionException(
        AccountDeletionError.reauthenticationUnavailable,
      );
    }

    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final credential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      await user.reauthenticateWithCredential(credential);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const AccountDeletionException(
          AccountDeletionError.reauthenticationCancelled,
        );
      }

      debugPrint("❌ Apple reauth error: ${e.code}");
      throw const AccountDeletionException(
        AccountDeletionError.reauthenticationFailed,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint("❌ Apple reauth auth error: ${e.code}");
      throw const AccountDeletionException(
        AccountDeletionError.reauthenticationFailed,
      );
    } catch (e) {
      debugPrint("❌ Apple reauth error: $e");
      throw const AccountDeletionException(
        AccountDeletionError.reauthenticationFailed,
      );
    }
  }
}
