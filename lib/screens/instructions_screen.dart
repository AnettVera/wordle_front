import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/example_row.dart';

class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('¿Cómo jugar?'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        '- Adivina la palabra oculta en 6 intentos.\n'
                        '- Cada intento debe ser una palabra válida de 5 letras.\n'
                        '- Después de cada intento, el color de las letras cambiará para mostrar qué tan cerca estás:',
                        style: TextStyle(fontSize: 18, color: AppColors.text),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      const ExampleRow(),
                      const SizedBox(height: 24),
                      const Text(
                        'Verde: Letra correcta y en la posición correcta.\n'
                        'Amarillo: Letra correcta pero en la posición incorrecta.\n'
                        'Gris: Letra no está en la palabra.',
                        style: TextStyle(fontSize: 18, color: AppColors.text),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 64),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkGrey,
                          foregroundColor: AppColors.text,
                          minimumSize: const Size(200, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Volver al juego'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
