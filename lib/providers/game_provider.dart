// providers/game_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/wordle_api_service.dart';
import '../theme/app_theme.dart';

class GameProvider extends ChangeNotifier {
  Game? _currentGame;
  bool _isLoading = false;
  String? _error;
  LinkStatusResponse? _linkStatus;
  bool _isAlexa = false;
  
  // Nueva funcionalidad para el teclado
  String _currentRowInput = '';
  int _currentRowIndex = 0;
  bool _allowLocalInput = false; // Para controlar si se permite input local

  // Getters existentes
  Game? get currentGame => _currentGame;
  bool get isLoading => _isLoading;
  String? get error => _error;
  LinkStatusResponse? get linkStatus => _linkStatus;
  bool get isAlexa => _isAlexa;

  // Nuevos getters para el teclado
  String get currentRowInput => _currentRowInput;
  int get currentRowIndex => _currentRowIndex;
  bool get allowLocalInput => _allowLocalInput;

  // Verificar si el usuario está autenticado
  bool get isAuthenticated => FirebaseAuth.instance.currentUser != null;
  String? get userEmail => FirebaseAuth.instance.currentUser?.email;

  // Obtener el estado actual del juego
  Future<void> fetchCurrentGame() async {
    if (!isAuthenticated) {
      _error = 'Usuario no autenticado';
      _currentGame = null;
      _isAlexa = false;
      _resetLocalInput();
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      final response = await WordleApiService.getCurrentGame();
      if (response.success && response.game != null) {
        _currentGame = response.game;
        _error = null;
        _isAlexa = response.game?.isLinkedToAlexa ?? false;
        _updateCurrentRowIndex();
        _resetLocalInput();
      } else {
        _currentGame = null;
        _error = response.error ?? 'Error desconocido';
        _isAlexa = false;
        _resetLocalInput();
      }
    } catch (e) {
      _currentGame = null;
      _error = e.toString();
      _isAlexa = false;
      _resetLocalInput();
    } finally {
      _setLoading(false);
    }
  }

  // Método para actualizar el estado de isAlexa
  void setAlexaStatus(bool status) {
    _isAlexa = status;
    notifyListeners();
  }

  // Método para habilitar/deshabilitar input local (para modo práctica)
  void setAllowLocalInput(bool allow) {
    _allowLocalInput = allow;
    if (!allow) {
      _resetLocalInput();
    }
    notifyListeners();
  }

  // Reiniciar juego
  Future<void> resetGame() async {
    if (!isAuthenticated) {
      _error = 'Usuario no autenticado';
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      final response = await WordleApiService.resetGame();
      if (response.success && response.game != null) {
        _currentGame = response.game;
        _error = null;
        _updateCurrentRowIndex();
        _resetLocalInput();
      } else {
        _error = response.error ?? 'Error al reiniciar el juego';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // NUEVOS MÉTODOS PARA EL TECLADO

  // Obtener la entrada actual de la fila activa
  String? getCurrentRowInput() {
    if (_allowLocalInput) {
      return _currentRowInput;
    }
    
    // Si no está en modo local, retornar null para indicar que no hay input local
    return null;
  }

  // Agregar una letra a la entrada actual
  void addLetter(String letter) {
    if (!_allowLocalInput) {
      throw Exception('Input local no está habilitado. Las palabras se ingresan desde Alexa.');
    }
    
    if (_currentRowInput.length < 5) {
      _currentRowInput += letter.toUpperCase();
      notifyListeners();
    }
  }

  // Eliminar la última letra
  void deleteLastLetter() {
    if (!_allowLocalInput) {
      throw Exception('Input local no está habilitado. Las palabras se ingresan desde Alexa.');
    }
    
    if (_currentRowInput.isNotEmpty) {
      _currentRowInput = _currentRowInput.substring(0, _currentRowInput.length - 1);
      notifyListeners();
    }
  }

  // Enviar palabra (para modo práctica)
  Future<void> submitWord(String word) async {
    if (!_allowLocalInput) {
      throw Exception('Input local no está habilitado. Las palabras se envían desde Alexa.');
    }
    
    if (!isAuthenticated) {
      throw Exception('Usuario no autenticado');
    }

    if (word.length != 5) {
      throw Exception('La palabra debe tener exactamente 5 letras');
    }

    _setLoading(true);
    try {
      // Aquí llamarías a tu API para enviar la palabra
      // final response = await WordleApiService.submitGuess(word);
      
      // Por ahora, simular el envío
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Después de enviar exitosamente, limpiar el input y actualizar el juego
      _currentRowInput = '';
      _currentRowIndex++;
      
      // Recargar el estado del juego
      await fetchCurrentGame();
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Verificar si el juego está completo
  bool get isGameComplete {
    if (_currentGame == null) return false;
    return _currentGame!.remainingAttempts <= 0 || 
           _currentGame!.attempts.any((attempt) => 
               attempt.feedback.every((f) => f.status == 'correct_pos'));
  }

  // Verificar si se puede seguir jugando
  bool get canContinuePlaying {
    if (_currentGame == null) return false;
    return !isGameComplete && _currentGame!.remainingAttempts > 0;
  }

  // MÉTODOS EXISTENTES MEJORADOS

  // Obtener matriz de letras para la cuadrícula (6x5)
  List<List<String>> getLettersMatrix() {
    List<List<String>> matrix = List.generate(6, (_) => List.filled(5, ''));

    if (_currentGame != null) {
      // Llenar con los intentos ya realizados
      for (int i = 0; i < _currentGame!.attempts.length && i < 6; i++) {
        final attempt = _currentGame!.attempts[i];
        for (int j = 0; j < attempt.guess.length && j < 5; j++) {
          matrix[i][j] = attempt.guess[j];
        }
      }

      // Si hay input local, mostrar la entrada actual en la fila activa
      if (_allowLocalInput && _currentRowIndex < 6 && _currentRowInput.isNotEmpty) {
        for (int j = 0; j < _currentRowInput.length && j < 5; j++) {
          matrix[_currentRowIndex][j] = _currentRowInput[j];
        }
      }
    }

    return matrix;
  }

  // Obtener matriz de colores para la cuadrícula
  List<List<Color>> getColorsMatrix() {
    List<List<Color>> matrix = List.generate(
      6,
      (_) => List.filled(5, AppColors.darkGrey),
    );

    if (_currentGame != null) {
      for (int i = 0; i < _currentGame!.attempts.length && i < 6; i++) {
        final attempt = _currentGame!.attempts[i];
        for (int j = 0; j < attempt.feedback.length && j < 5; j++) {
          final feedback = attempt.feedback[j];
          matrix[i][j] = _getColorForStatus(feedback.status);
        }
      }

      // Si hay input local, mostrar colores de entrada en la fila activa
      if (_allowLocalInput && _currentRowIndex < 6 && _currentRowInput.isNotEmpty) {
        for (int j = 0; j < _currentRowInput.length && j < 5; j++) {
          matrix[_currentRowIndex][j] = AppColors.cellBorder; // Color para letras no enviadas
        }
      }
    }

    return matrix;
  }

  // Convertir el status del backend a color
  Color _getColorForStatus(String status) {
    switch (status) {
      case 'correct_pos':
        return AppColors.green;
      case 'correct_wrong_pos':
        return AppColors.yellow;
      case 'not_in_word':
        return AppColors.darkGrey.withOpacity(0.7);
      default:
        return AppColors.darkGrey;
    }
  }

  // Obtener estado de las letras del teclado
  Map<String, String?> getKeyboardLetterStates() {
    Map<String, String?> states = {};

    if (_currentGame != null) {
      for (final attempt in _currentGame!.attempts) {
        for (final feedback in attempt.feedback) {
          final letter = feedback.letter.toUpperCase();
          final currentStatus = states[letter];

          // Prioridad: correct_pos > correct_wrong_pos > not_in_word
          if (currentStatus != 'correct_pos') {
            if (feedback.status == 'correct_pos' ||
                (feedback.status == 'correct_wrong_pos' &&
                    currentStatus != 'correct_wrong_pos')) {
              states[letter] = feedback.status;
            } else if (currentStatus == null) {
              states[letter] = feedback.status;
            }
          }
        }
      }
    }

    return states;
  }

  // MÉTODOS PRIVADOS PARA MANEJO INTERNO

  void _updateCurrentRowIndex() {
    if (_currentGame != null) {
      _currentRowIndex = _currentGame!.attempts.length;
    } else {
      _currentRowIndex = 0;
    }
  }

  void _resetLocalInput() {
    _currentRowInput = '';
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Método para limpiar todo el estado (útil para logout)
  void clearGameState() {
    _currentGame = null;
    _error = null;
    _isAlexa = false;
    _resetLocalInput();
    _currentRowIndex = 0;
    _allowLocalInput = false;
    notifyListeners();
  }
}