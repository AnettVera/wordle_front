import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LetterBox extends StatelessWidget {
  final String letter;
  final Color color;
  final bool animate;

  const LetterBox({
    Key? key,
    required this.letter,
    required this.color,
    this.animate = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      width: 52,
      height: 52,
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          if (animate)
            const BoxShadow(
              color: Colors.white24,
              blurRadius: 8,
              spreadRadius: 1,
              offset: Offset(0, 2),
            ),
        ],
        border: Border.all(color: AppColors.cellBorder, width: .5),
      ),
      alignment: Alignment.center,
      child: Text(
        letter.toUpperCase(),
        style: const TextStyle(
          fontSize: 28,
          color: AppColors.text,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
          shadows: [
            Shadow(
              color: Colors.white24,
              blurRadius: 6,
              offset: Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }
}
