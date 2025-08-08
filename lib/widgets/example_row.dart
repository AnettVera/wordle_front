import 'package:flutter/material.dart';
import '../widgets/letter_box.dart';
import '../theme/app_theme.dart';

class ExampleRow extends StatelessWidget {
  const ExampleRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ejemplo visual para instrucciones
    final List<String> letters = ['C', 'A', 'S', 'A', 'S'];
    final List<Color> colors = [
      AppColors.green,
      AppColors.yellow,
      AppColors.darkGrey,
      AppColors.darkGrey,
      AppColors.green,
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        return SizedBox(
          width: 55, // Ajusta este valor según lo que necesites
          height: 55,
          child: LetterBox(
            letter: letters[i],
            color: colors[i],
            animate: false,
          ),
        );
      }),
    );
  }
}
