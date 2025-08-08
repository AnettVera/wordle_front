// screens/game_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/header_bar.dart';
import '../widgets/wordle_grid.dart';
import '../widgets/wordle_keyboard.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../services/link_service.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar el juego actual al inicializar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().fetchCurrentGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAlexa = Provider.of<GameProvider>(context).isAlexa;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 400;
    final isLargeScreen = screenWidth > 600;
    
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: HeaderBar(),
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight - 120, // Altura mínima considerando el AppBar
                ),
                child: Column(
                  children: [
                    // Mostrar mensaje de error si existe
                    if (gameProvider.error != null)
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 12 : 16,
                          vertical: 8,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Colors.red.shade300),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                gameProvider.error!,
                                style: TextStyle(color: Colors.red.shade300),
                              ),
                            ),
                            IconButton(
                              onPressed: gameProvider.clearError,
                              icon: Icon(Icons.close, color: Colors.red.shade300),
                              iconSize: 18,
                            ),
                          ],
                        ),
                      ),

                    // Mostrar estado del juego
                    _buildGameStatusSection(gameProvider, isAlexa, isSmallScreen),

                    // Espaciado flexible
                    SizedBox(height: isSmallScreen ? 16 : 24),

                    // Indicador de carga
                    if (gameProvider.isLoading)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(color: AppColors.text),
                      ),

                    // Grilla del juego
                    const WordleGrid(),
                    
                    SizedBox(height: isSmallScreen ? 18 : 32),
                    
                    // Teclado
                    const WordleKeyboard(),
                    
                    SizedBox(height: isSmallScreen ? 18 : 24),

                    // Botones de acción - Responsive
                    _buildActionButtons(gameProvider, isSmallScreen, isLargeScreen),
                    
                    SizedBox(height: isSmallScreen ? 16 : 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameStatusSection(GameProvider gameProvider, bool isAlexa, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: 8,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkGrey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: (isAlexa == false)
          ? Column(
              children: [
                SizedBox(height: isSmallScreen ? 24 : 32),
                Icon(Icons.link_off, size: isSmallScreen ? 48 : 64, color: Colors.grey),
                SizedBox(height: isSmallScreen ? 12 : 16),
                Text(
                  'Vincula tu cuenta para comenzar a jugar.',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18, 
                    color: Colors.grey
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            )
          : (gameProvider.currentGame == null)
              ? Column(
                  children: [
                    SizedBox(height: isSmallScreen ? 24 : 32),
                    Icon(Icons.link_off, size: isSmallScreen ? 48 : 64, color: Colors.grey),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    Text(
                      'No hay un juego activo.',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18, 
                        color: Colors.grey
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : Column(
                  children: [
                    Text(
                      gameProvider.currentGame!.message,
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    _buildGameStats(gameProvider, isSmallScreen),
                  ],
                ),
    );
  }

  Widget _buildGameStats(GameProvider gameProvider, bool isSmallScreen) {
    // En pantallas muy pequeñas, usar columna en lugar de fila
    if (isSmallScreen) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                'Intentos usados',
                '${gameProvider.currentGame!.usedAttempts}',
                isSmallScreen,
              ),
              _buildStatItem(
                'Restantes',
                '${gameProvider.currentGame!.remainingAttempts}',
                isSmallScreen,
              ),
            ],
          ),
          if (gameProvider.currentGame!.isLinkedToAlexa)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _buildStatItem('Estado', 'Vinculado', isSmallScreen),
            ),
        ],
      );
    }

    // En pantallas normales, mantener la fila
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(
          'Intentos usados',
          '${gameProvider.currentGame!.usedAttempts}',
          isSmallScreen,
        ),
        _buildStatItem(
          'Restantes',
          '${gameProvider.currentGame!.remainingAttempts}',
          isSmallScreen,
        ),
        if (gameProvider.currentGame!.isLinkedToAlexa)
          _buildStatItem('Estado', 'Vinculado', isSmallScreen),
      ],
    );
  }

  Widget _buildActionButtons(GameProvider gameProvider, bool isSmallScreen, bool isLargeScreen) {
    final buttonHeight = isSmallScreen ? 45.0 : 50.0;
    final buttonWidth = isSmallScreen ? 140.0 : 160.0;
    final fontSize = isSmallScreen ? 14.0 : 16.0;
    
    // En pantallas muy pequeñas, usar columna
    if (isSmallScreen) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: buttonHeight,
              child: ElevatedButton.icon(
                onPressed: gameProvider.isLoading
                    ? null
                    : () => gameProvider.fetchCurrentGame(),
                icon: Icon(Icons.refresh, size: isSmallScreen ? 16 : 20),
                label: Text('Actualizar', style: TextStyle(fontSize: fontSize)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGrey,
                  foregroundColor: AppColors.text,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: buttonHeight,
              child: ElevatedButton.icon(
                onPressed: gameProvider.isLoading ? null : () => _unlinkAccount(gameProvider),
                icon: Icon(Icons.link_off, size: isSmallScreen ? 16 : 20),
                label: Text('Desvincular', style: TextStyle(fontSize: fontSize)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // En pantallas normales y grandes, usar fila
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 32.0 : 16.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: SizedBox(
              width: buttonWidth,
              height: buttonHeight,
              child: ElevatedButton.icon(
                onPressed: gameProvider.isLoading
                    ? null
                    : () => gameProvider.fetchCurrentGame(),
                icon: Icon(Icons.refresh, size: isSmallScreen ? 16 : 20),
                label: Text('Actualizar', style: TextStyle(fontSize: fontSize)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGrey,
                  foregroundColor: AppColors.text,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: isLargeScreen ? 24 : 16),
          Flexible(
            child: SizedBox(
              width: buttonWidth,
              height: buttonHeight,
              child: ElevatedButton.icon(
                onPressed: gameProvider.isLoading ? null : () => _unlinkAccount(gameProvider),
                icon: Icon(Icons.link_off, size: isSmallScreen ? 16 : 20),
                label: Text('Desvincular', style: TextStyle(fontSize: fontSize)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _unlinkAccount(GameProvider gameProvider) async {
    try {
      final response = await LinkService.unlinkAccount();
      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cuenta desvinculada exitosamente'),
            ),
          );
          // Volver a cargar el juego para reflejar desvinculación
          await gameProvider.fetchCurrentGame();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${response['error']}'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al desvincular: $e'),
          ),
        );
      }
    }
  }

  Widget _buildStatItem(String label, String value, bool isSmallScreen) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: AppColors.text,
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.text.withOpacity(0.7),
            fontSize: isSmallScreen ? 10 : 12,
          ),
        ),
      ],
    );
  }
}