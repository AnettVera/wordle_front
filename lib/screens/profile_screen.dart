import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            const CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.darkGrey,
              child: Icon(Icons.person, size: 48, color: AppColors.text),
            ),
            const SizedBox(height: 16),
            Text(
              user?.email ?? 'Usuario',
              style: const TextStyle(
                fontSize: 20, 
                color: AppColors.text, 
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bienvenidx a Wordle',
              style: const TextStyle(
                fontSize: 16, 
                color: AppColors.text
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _StatBox(label: 'Adivinadas', value: '12'),
                _StatBox(label: 'Fallidas', value: '5'),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                // Mostrar diálogo de confirmación
                bool shouldLogout = await _showLogoutDialog(context);
                if (shouldLogout) {
                  await authService.signOut();
                  // Regresar al AuthWrapper que detectará el cambio y mostrará LoginScreen
                  if (context.mounted) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cerrar sesión',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<bool> _showLogoutDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: const Text(
            'Cerrar Sesión', 
            style: TextStyle(color: AppColors.text)
          ),
          content: const Text(
            '¿Estás seguro de que quieres cerrar sesión?',
            style: TextStyle(color: AppColors.text)
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppColors.text)
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cerrar sesión'),
            ),
          ],
        );
      },
    ) ?? false;
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 28, color: AppColors.green, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: AppColors.text),
        ),
      ],
    );
  }
}