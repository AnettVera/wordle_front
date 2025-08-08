// widgets/wordle_grid.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/letter_box.dart';
import '../providers/game_provider.dart';

class WordleGrid extends StatelessWidget {
  const WordleGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        // Obtener las matrices de letras y colores del provider
        final letters = gameProvider.getLettersMatrix();
        final colors = gameProvider.getColorsMatrix();

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (row) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (col) {
                return LetterBox(
                  letter: letters[row][col],
                  color: colors[row][col],
                  animate: false, // Podrías agregar animaciones basadas en el estado del juego
                );
              }),
            );
          }),
        );
      },
    );
  }
}