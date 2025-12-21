import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Текущий пользователь
  User? get currentUser => _auth.currentUser;

  // Поток изменений состояния (для main.dart и ProfileScreen)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // --- 1. АНОНИМНЫЙ ВХОД (ГОСТЬ) ---
  Future<User?> signInAnonymously() async {
    try {
      final UserCredential userCredential = await _auth.signInAnonymously();
      print("Вход выполнен анонимно: ${userCredential.user?.uid}");
      return userCredential.user;
    } catch (e) {
      print("Ошибка анонимного входа: $e");
      return null;
    }
  }

  // --- 2. ВХОД ЧЕРЕЗ GOOGLE ---
  Future<User?> signInWithGoogle() async {
    try {
      // Запускаем процесс входа Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Пользователь отменил вход

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // ВАЖНЫЙ МОМЕНТ:
      // Если пользователь уже аноним, мы пытаемся "Привязать" (Link) Google к анониму.
      // Если нет — просто входим.
      if (_auth.currentUser != null && _auth.currentUser!.isAnonymous) {
        try {
          final userCredential = await _auth.currentUser!.linkWithCredential(credential);
          print("Анонимный аккаунт успешно обновлен до Google!");
          return userCredential.user;
        } on FirebaseAuthException catch (e) {
          // Если аккаунт Google уже существует, link выдаст ошибку.
          // В этом случае мы просто переключаемся на этот Google аккаунт.
          if (e.code == 'credential-already-in-use') {
            print("Этот Google аккаунт уже существует. Переключаемся...");
            // Просто входим (данные анонима останутся в старом UID, это нормально для MVP)
            final userCredential = await _auth.signInWithCredential(credential);
            return userCredential.user;
          }
        }
      }

      // Обычный вход (если не были анонимом)
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;

    } catch (e) {
      print("Ошибка входа через Google: $e");
      return null;
    }
  }

  // --- 3. ВЫХОД ---
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      print("Выход выполнен");
    } catch (e) {
      print("Ошибка при выходе: $e");
    }
  }
}