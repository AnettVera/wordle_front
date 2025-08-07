import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/instructions_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/matchcount_screen.dart';

class HeaderBar extends StatelessWidget {
  const HeaderBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40), 
          const Text(
            'WORDLE',
            style: TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.bold,
              fontSize: 28,
              letterSpacing: 4,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.person_outline, color: AppColors.text),
                onPressed: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const ProfileScreen(),
                      transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.link, color: AppColors.text),
                tooltip: 'Vincular con Alexa',
                onPressed: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const MatchcountScreen(),
                      transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.menu_book_outlined, color: AppColors.text),
                onPressed: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const InstructionsScreen(),
                      transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
