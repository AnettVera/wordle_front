import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  int _failedAttempts = 0;
  DateTime? _lastFailedAttempt;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Validación de email mejorada
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu email';
    }
    
    String trimmedValue = value.trim().toLowerCase();
    
    // Verificar formato básico
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(trimmedValue)) {
      return 'Formato de email inválido';
    }
    
    // Verificar que no tenga espacios
    if (trimmedValue.contains(' ')) {
      return 'El email no puede contener espacios';
    }
    
    // Verificar longitud
    if (trimmedValue.length < 5) {
      return 'Email muy corto';
    }
    
    if (trimmedValue.length > 50) {
      return 'Email muy largo (máximo 50 caracteres)';
    }
    
    return null;
  }

  // Validación de contraseña para login
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu contraseña';
    }
    
    // Para login, validaciones más permisivas (el usuario ya tiene cuenta)
    if (value.length < 6) {
      return 'Contraseña muy corta';
    }
    
    if (value.length > 128) {
      return 'Contraseña muy larga';
    }
    
    // Verificar que no sea solo espacios
    if (value.trim().isEmpty) {
      return 'La contraseña no puede estar vacía';
    }
    
    return null;
  }

  // Verificar si el usuario está bloqueado temporalmente
  bool _isTemporarilyBlocked() {
    if (_failedAttempts < 3) return false;
    
    if (_lastFailedAttempt != null) {
      final timeSinceLastAttempt = DateTime.now().difference(_lastFailedAttempt!);
      if (timeSinceLastAttempt.inMinutes < 5) {
        return true;
      } else {
        // Reset después de 5 minutos
        _failedAttempts = 0;
        _lastFailedAttempt = null;
        return false;
      }
    }
    
    return false;
  }

  Future<void> _signIn() async {
    // Verificar bloqueo temporal
    if (_isTemporarilyBlocked()) {
      final remainingTime = 5 - DateTime.now().difference(_lastFailedAttempt!).inMinutes;
      _showErrorSnackBar('Demasiados intentos fallidos. Espera $remainingTime minutos.');
      return;
    }

    // Limpiar espacios en blanco del email
    _emailController.text = _emailController.text.trim().toLowerCase();
    
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.signInWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );
      
      // Reset failed attempts on successful login
      _failedAttempts = 0;
      _lastFailedAttempt = null;
      
      // AuthWrapper se encargará de navegar automáticamente al GameScreen
    } on FirebaseAuthException catch (e) {
      // Incrementar intentos fallidos
      _failedAttempts++;
      _lastFailedAttempt = DateTime.now();
      
      String errorMessage = _authService.getErrorMessage(e);
      
      // Agregar información sobre bloqueo si es necesario
      if (_failedAttempts >= 3) {
        errorMessage += '\n\nDemasiados intentos fallidos. Espera 5 minutos antes de intentar de nuevo.';
      } else if (_failedAttempts >= 2) {
        errorMessage += '\n\nIntento ${_failedAttempts} de 3. Ten cuidado.';
      }
      
      _showErrorSnackBar(errorMessage);
    } catch (e) {
      _failedAttempts++;
      _lastFailedAttempt = DateTime.now();
      _showErrorSnackBar('Error inesperado. Verifica tu conexión e inténtalo de nuevo.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Cerrar',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: const Text(
          'Recuperar Contraseña',
          style: TextStyle(color: AppColors.text),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ingresa tu email para recibir un enlace de recuperación',
              style: TextStyle(color: AppColors.text),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: AppColors.text),
              decoration: const InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: AppColors.text),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.green),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.text),
            ),
          ),
          TextButton(
            onPressed: () async {
              String email = emailController.text.trim().toLowerCase();
              if (email.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ingresa un email válido'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Enlace de recuperación enviado. Revisa tu email.'),
                    backgroundColor: AppColors.green,
                    duration: Duration(seconds: 4),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error al enviar el email. Verifica que la dirección sea correcta.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Enviar',
              style: TextStyle(color: AppColors.green),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBlocked = _isTemporarilyBlocked();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo/Título
                const Text(
                  'WORDLE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 48,
                    letterSpacing: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isBlocked 
                      ? 'Cuenta bloqueada temporalmente'
                      : 'Inicia sesión para jugar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isBlocked ? Colors.red : AppColors.text,
                    fontSize: 16,
                  ),
                ),
                if (_failedAttempts > 0 && !isBlocked)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Intentos fallidos: $_failedAttempts/3',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 14,
                      ),
                    ),
                  ),
                const SizedBox(height: 48),

                // Campo Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  enabled: !isBlocked,
                  style: const TextStyle(color: AppColors.text),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: AppColors.text),
                    prefixIcon: Icon(Icons.email_outlined, color: AppColors.text),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.green),
                    ),
                  ),
                  validator: _validateEmail,
                  onChanged: (value) {
                    // Limpiar espacios en tiempo real
                    if (value.contains(' ')) {
                      _emailController.text = value.replaceAll(' ', '');
                      _emailController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _emailController.text.length),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Campo Contraseña
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  enabled: !isBlocked,
                  style: const TextStyle(color: AppColors.text),
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: const TextStyle(color: AppColors.text),
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.text),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.text,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: const OutlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.green),
                    ),
                  ),
                  validator: _validatePassword,
                  onFieldSubmitted: (_) => _signIn(),
                ),
                const SizedBox(height: 8),

                // Enlace Olvidé mi contraseña
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: isBlocked ? null : _showForgotPasswordDialog,
                    child: const Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(
                        color: AppColors.green,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Botón Iniciar Sesión
                ElevatedButton(
                  onPressed: (_isLoading || isBlocked) ? null : _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isBlocked ? 'Cuenta Bloqueada' : 'Iniciar Sesión',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 16),

                // Botón Registrarse
                TextButton(
                  onPressed: (_isLoading || isBlocked)
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterScreen()),
                          );
                        },
                  child: const Text(
                    '¿No tienes cuenta? Regístrate',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}