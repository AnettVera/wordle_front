import 'package:flutter/material.dart';
import '../widgets/header_bar.dart';
import '../widgets/wordle_grid.dart';
import '../widgets/wordle_keyboard.dart';
import '../theme/app_theme.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: HeaderBar(),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          const WordleGrid(),
          const SizedBox(height: 32),
          const WordleKeyboard(),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkGrey,
                foregroundColor: AppColors.text,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Reiniciar Juego'),
            ),
          ),
        ],
      ),
    );
  }
}
