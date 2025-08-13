import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
      return 'Ingresa un email válido';
    }
    
    // Verificar que no tenga espacios
    if (trimmedValue.contains(' ')) {
      return 'El email no puede contener espacios';
    }
    
    // Verificar longitud mínima y máxima
    if (trimmedValue.length < 5) {
      return 'El email es muy corto';
    }
    
    if (trimmedValue.length > 50) {
      return 'El email es muy largo (máximo 50 caracteres)';
    }
    
    // Verificar que no tenga puntos consecutivos
    if (trimmedValue.contains('..')) {
      return 'El email no puede tener puntos consecutivos';
    }
    
    // Verificar que no empiece o termine con punto
    if (trimmedValue.startsWith('.') || trimmedValue.endsWith('.')) {
      return 'El email no puede empezar o terminar con punto';
    }
    
    return null;
  }

  // Validación de contraseña mejorada
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa una contraseña';
    }
    
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    
    if (value.length > 128) {
      return 'La contraseña es muy larga (máximo 128 caracteres)';
    }
    
    // Verificar que no tenga solo espacios
    if (value.trim().isEmpty) {
      return 'La contraseña no puede estar vacía';
    }
    
    // Verificar complejidad
    bool hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
    bool hasLowercase = RegExp(r'[a-z]').hasMatch(value);
    bool hasDigits = RegExp(r'[0-9]').hasMatch(value);
    bool hasSpecialCharacters = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);
    
    List<String> missing = [];
    if (!hasUppercase) missing.add('mayúscula');
    if (!hasLowercase) missing.add('minúscula');
    if (!hasDigits) missing.add('número');
    if (!hasSpecialCharacters) missing.add('carácter especial');
    
    if (missing.length > 2) {
      return 'Contraseña débil. Incluye al menos: mayúsculas, minúsculas, números y símbolos';
    }
    
    // Verificar patrones comunes débiles
    if (RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'No uses solo números';
    }
    
    if (RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
      return 'Incluye números o símbolos';
    }
    
    // Verificar secuencias comunes
    List<String> commonPatterns = ['123456', 'abcdef', 'qwerty', 'password', '111111'];
    for (String pattern in commonPatterns) {
      if (value.toLowerCase().contains(pattern)) {
        return 'Evita usar secuencias o palabras comunes';
      }
    }
    
    return null;
  }

  // Validación de confirmación de contraseña
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    
    if (value != _passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    
    return null;
  }

  Future<void> _register() async {
    // Limpiar espacios en blanco del email
    _emailController.text = _emailController.text.trim().toLowerCase();
    
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.registerWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );
      
      // Mostrar mensaje de éxito
      _showSuccessSnackBar('¡Cuenta creada exitosamente!');
      
      // Regresar a login (AuthWrapper se encargará de la navegación)
      Navigator.pop(context);
      
    } on FirebaseAuthException catch (e) {
      _showErrorSnackBar(_authService.getErrorMessage(e));
    } catch (e) {
      _showErrorSnackBar('Error inesperado. Inténtalo de nuevo.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Cerrar',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Crear Cuenta', style: TextStyle(color: AppColors.text)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
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
                  'REGISTRO',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Crea tu cuenta para empezar a jugar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 48),

                // Campo Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: AppColors.text),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: AppColors.text),
                    prefixIcon: Icon(Icons.email_outlined, color: AppColors.text),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.green),
                    ),
                    helperText: 'Ejemplo: usuario@correo.com',
                    helperStyle: TextStyle(color: AppColors.text, fontSize: 12),
                  ),
                  validator: _validateEmail,
                  onChanged: (value) {
                    // Limpiar en tiempo real
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
                  textInputAction: TextInputAction.next,
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
                    helperText: 'Mínimo 8 caracteres con mayúsculas, números y símbolos',
                    helperStyle: const TextStyle(color: AppColors.text, fontSize: 12),
                    helperMaxLines: 2,
                  ),
                  validator: _validatePassword,
                  onChanged: (value) {
                    // Revalidar confirmación de contraseña cuando cambie la contraseña
                    if (_confirmPasswordController.text.isNotEmpty) {
                      _formKey.currentState?.validate();
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Campo Confirmar Contraseña
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(color: AppColors.text),
                  decoration: InputDecoration(
                    labelText: 'Confirmar Contraseña',
                    labelStyle: const TextStyle(color: AppColors.text),
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.text),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                        color: AppColors.text,
                      ),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    border: const OutlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.green),
                    ),
                  ),
                  validator: _validateConfirmPassword,
                  onFieldSubmitted: (_) => _register(),
                ),
                const SizedBox(height: 32),

                // Botón Registrarse
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
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
                      : const Text(
                          'Crear Cuenta',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 16),

                // Texto ya tienes cuenta
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text(
                    '¿Ya tienes cuenta? Inicia sesión',
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