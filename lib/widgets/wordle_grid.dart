import 'package:flutter/material.dart';
import '../widgets/letter_box.dart';
import '../theme/app_theme.dart';

class WordleGrid extends StatelessWidget {
  const WordleGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ejemplo estático: 6 filas x 5 columnas
    final List<List<String>> letters = [
      ['P', 'L', 'A', 'T', 'O'],
      ['P', 'R', 'A', 'D', 'O'],
      ['', '', '', '', ''],
      ['', '', '', '', ''],
      ['', '', '', '', ''],
      ['', '', '', '', ''],
    ];
    final List<List<Color>> colors = [
      [AppColors.green, AppColors.green, AppColors.darkGrey, AppColors.yellow, AppColors.darkGrey],
      [AppColors.green, AppColors.green, AppColors.yellow, AppColors.darkGrey, AppColors.green],
      [AppColors.darkGrey, AppColors.darkGrey, AppColors.darkGrey, AppColors.darkGrey, AppColors.darkGrey],
      [AppColors.darkGrey, AppColors.darkGrey, AppColors.darkGrey, AppColors.darkGrey, AppColors.darkGrey],
      [AppColors.darkGrey, AppColors.darkGrey, AppColors.darkGrey, AppColors.darkGrey, AppColors.darkGrey],
      [AppColors.darkGrey, AppColors.darkGrey, AppColors.darkGrey, AppColors.darkGrey, AppColors.darkGrey],
    ];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (col) {
            return LetterBox(
              letter: letters[row][col],
              color: colors[row][col],
              animate: false,
            );
          }),
        );
      }),
    );
  }
}
