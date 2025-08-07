import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream para escuchar cambios en la autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuario actual
  User? get currentUser => _auth.currentUser;

  // Registro con email y contraseña
  Future<UserCredential?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      print('Error en registro: ${e.message}');
      throw e;
    }
  }

  // Inicio de sesión con email y contraseña
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      print('Error en inicio de sesión: ${e.message}');
      throw e;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
  }

  // Obtener mensaje de error en español
  String getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'La contraseña es demasiado débil.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este email.';
      case 'invalid-email':
        return 'El email no es válido.';
      case 'user-not-found':
        return 'No se encontró usuario con este email.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'invalid-credential':
        return 'Credenciales inválidas.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Inténtalo más tarde.';
      default:
        return 'Error de autenticación: ${e.message}';
    }
  }
}