// widgets/wordle_keyboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';

class WordleKeyboard extends StatelessWidget {
  const WordleKeyboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
    final List<List<String>> keys = [
      ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
      ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'Ñ'],
      ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
    ];

    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final letterStates = gameProvider.getKeyboardLetterStates();
        
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8), // Padding fijo mínimo
          child: Column(
            children: List.generate(keys.length, (rowIndex) {
              return Padding(
                padding: EdgeInsets.only(bottom: 4), // Espacio vertical mínimo
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Espaciador muy pequeño para centrar la fila del medio
                    if (rowIndex == 1) 
                      SizedBox(width: 15),
                    
                    // Generar las teclas sin Flexible y con espaciado mínimo
                    ...keys[rowIndex].asMap().entries.map((entry) {
                      int index = entry.key;
                      String key = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(
                          right: index < keys[rowIndex].length - 1 ? 3 : 0, // Solo espacio a la derecha excepto la última
                        ),
                        child: _buildKeyButton(key, letterStates[key], isSmallScreen),
                      );
                    }).toList(),
                    
                    // Espaciador para centrar la fila del medio
                    if (rowIndex == 1) 
                      SizedBox(width: 15),
                  ],
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildKeyButton(String key, String? status, bool isSmallScreen) {
    // Obtener colores basados en el estado de la letra
    final colors = _getKeyColors(status);
    
    // Dimensiones más compactas y fijas
    final double buttonWidth = 30; // Ancho fijo
    final double buttonHeight = 40; // Alto fijo
    final double fontSize = 15; // Tamaño de fuente fijo

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: () {
          // Teclado visual - sin funcionalidad de input
          // Solo Alexa envía las palabras
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: colors['background'],
          foregroundColor: colors['text'],
          padding: EdgeInsets.zero, // Sin padding interno
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          elevation: 1,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Elimina padding adicional
        ),
        child: Text(
          key,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: colors['text'],
          ),
        ),
      ),
    );
  }

  // Función para obtener colores basados en el estado de la letra
  Map<String, Color> _getKeyColors(String? status) {
    Color backgroundColor = AppColors.darkGrey;
    Color textColor = AppColors.text;

    // Cambiar color basado en el estado de la letra
    switch (status) {
      case 'correct_pos':
        backgroundColor = AppColors.green;
        textColor = Colors.white;
        break;
      case 'correct_wrong_pos':
        backgroundColor = AppColors.yellow;
        textColor = Colors.black;
        break;
      case 'not_in_word':
        backgroundColor = AppColors.darkGrey.withOpacity(0.5);
        textColor = Colors.grey.shade400;
        break;
    }

    return {
      'background': backgroundColor,
      'text': textColor,
    };
  }
}