// lib/widgets/header_bar.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/instructions_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/matchcount_screen.dart';
import '../screens/history_screen.dart';

class HeaderBar extends StatelessWidget {
  const HeaderBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          // Espaciador izquierdo flexible
          const Spacer(),
          
          // Título central
          Flexible(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'WORDLE',
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
          ),
          
          // Espaciador derecho flexible
          const Spacer(),
          
          // Iconos de navegación - responsive
          screenWidth < 400 ? _buildCompactIcons(context) : _buildFullIcons(context),
        ],
      ),
    );
  }

  // Versión completa para pantallas grandes
  Widget _buildFullIcons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.person_outline, color: AppColors.text),
          tooltip: 'Perfil',
          iconSize: 22,
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          onPressed: () => _navigateToScreen(context, const ProfileScreen()),
        ),
        IconButton(
          icon: const Icon(Icons.history, color: AppColors.text),
          tooltip: 'Historial',
          iconSize: 22,
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          onPressed: () => _navigateToScreen(context, const HistoryScreen()),
        ),
        IconButton(
          icon: const Icon(Icons.link, color: AppColors.text),
          tooltip: 'Vincular con Alexa',
          iconSize: 22,
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          onPressed: () => _navigateToScreen(context, const MatchcountScreen()),
        ),
        IconButton(
          icon: const Icon(Icons.menu_book_outlined, color: AppColors.text),
          tooltip: 'Instrucciones',
          iconSize: 22,
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          onPressed: () => _navigateToScreen(context, const InstructionsScreen()),
        ),
      ],
    );
  }

  // Versión compacta con menú desplegable para pantallas pequeñas
  Widget _buildCompactIcons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.person_outline, color: AppColors.text),
          tooltip: 'Perfil',
          iconSize: 20,
          padding: const EdgeInsets.all(6),
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          onPressed: () => _navigateToScreen(context, const ProfileScreen()),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.text, size: 20),
          tooltip: 'Más opciones',
          padding: const EdgeInsets.all(6),
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          color: AppColors.darkGrey,
          onSelected: (value) {
            switch (value) {
              case 'history':
                _navigateToScreen(context, const HistoryScreen());
                break;
              case 'link':
                _navigateToScreen(context, const MatchcountScreen());
                break;
              case 'instructions':
                _navigateToScreen(context, const InstructionsScreen());
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'history',
              child: Row(
                children: [
                  Icon(Icons.history, color: AppColors.text, size: 20),
                  SizedBox(width: 8),
                  Text('Historial', style: TextStyle(color: AppColors.text)),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'link',
              child: Row(
                children: [
                  Icon(Icons.link, color: AppColors.text, size: 20),
                  SizedBox(width: 8),
                  Text('Vincular con Alexa', style: TextStyle(color: AppColors.text)),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'instructions',
              child: Row(
                children: [
                  Icon(Icons.menu_book_outlined, color: AppColors.text, size: 20),
                  SizedBox(width: 8),
                  Text('Instrucciones', style: TextStyle(color: AppColors.text)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, anim, __, child) => 
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }
}