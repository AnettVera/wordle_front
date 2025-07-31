import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WordleKeyboard extends StatelessWidget {
  const WordleKeyboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Teclado estático de ejemplo
    final List<List<String>> keys = [];
    return Column(
      children: List.generate(keys.length, (row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: keys[row].map((key) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGrey,
                  foregroundColor: AppColors.text,
                  minimumSize: const Size(38, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  key,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }),
    );
  }
}
