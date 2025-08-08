// lib/providers/history_provider.dart (con corrección de zona horaria)
import 'package:flutter/material.dart';
import '../services/history_service.dart';
import '../models/game_history.dart';
import '../utils/timezone_helper.dart';

class HistoryProvider with ChangeNotifier {
  final HistoryService _historyService = HistoryService();

  List<GameHistory> _allGames = []; // Todos los juegos sin filtrar
  List<GameHistory> _games = []; // Juegos filtrados para mostrar
  GameSummary? _summary;
  PaginationInfo? _paginationInfo;
  MonthlyStats? _monthlyStats;
  bool _isLoading = false;
  String? _error;
  String _currentFilter = 'all';
  int _currentPage = 1;
  
  // Getters
  List<GameHistory> get games => _games;
  GameSummary? get summary => _summary;
  PaginationInfo? get paginationInfo => _paginationInfo;
  MonthlyStats? get monthlyStats => _monthlyStats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentFilter => _currentFilter;
  int get currentPage => _currentPage;

  // Método para ajustar fecha a zona horaria mexicana
  DateTime _adjustToMexicanTimezone(DateTime utcDate) {
    // Usar el helper de timezone para un manejo más preciso
    return TimezoneHelper.convertToMexicoCity(utcDate);
  }

  // Aplicar filtro del lado cliente
  void _applyClientSideFilter(String filter) {
    switch (filter) {
      case 'won':
        _games = _allGames.where((game) => game.isWon).toList();
        break;
      case 'lost':
        _games = _allGames.where((game) => game.isLost || !game.isWon).toList();
        break;
      case 'all':
      default:
        _games = List.from(_allGames);
        break;
    }
  }

  Future<void> loadGameHistory({
    int limit = 50,
    int offset = 0,
    String sortBy = 'completedAt',
    String sortOrder = 'desc',
    String filter = 'all',
    String? dateFrom,
    String? dateTo,
    bool clearPrevious = false,
  }) async {
    if (clearPrevious) {
      _allGames.clear();
      _games.clear();
      _currentPage = 1;
    }
    
    _isLoading = true;
    _error = null;
    _currentFilter = filter;
    notifyListeners();

    try {
      // SIEMPRE cargar todos los juegos sin filtro del servidor
      // Solo aplicar el filtro del lado cliente
      final response = await _historyService.getGameHistory(
        limit: limit,
        offset: offset,
        sortBy: sortBy,
        sortOrder: sortOrder,
        filter: 'all', // Siempre usar 'all' para evitar problemas de índices
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

      if (response['success'] == true) {
        // Verificar que games sea una lista
        final gamesData = response['games'];
        if (gamesData is List) {
          final newGames = <GameHistory>[];
          
          for (var gameData in gamesData) {
            try {
              if (gameData is Map<String, dynamic>) {
                newGames.add(GameHistory.fromJson(gameData));
              } else {
                print('Formato de juego inválido: $gameData');
              }
            } catch (e) {
              print('Error al parsear juego: $e');
              print('Datos del juego: $gameData');
            }
          }
          
          if (clearPrevious) {
            _allGames = newGames;
          } else {
            _allGames.addAll(newGames);
          }

          // Aplicar filtro del lado cliente
          _applyClientSideFilter(filter);
        }
        
        // Parsear summary si existe
        final summaryData = response['summary'];
        if (summaryData is Map<String, dynamic>) {
          try {
            _summary = GameSummary.fromJson(summaryData);
          } catch (e) {
            print('Error al parsear summary: $e');
            print('Datos del summary: $summaryData');
          }
        }
        
        // Parsear pagination si existe
        final paginationData = response['pagination'];
        if (paginationData is Map<String, dynamic>) {
          try {
            _paginationInfo = PaginationInfo.fromJson(paginationData);
            _currentPage = _paginationInfo?.currentPage ?? 1;
          } catch (e) {
            print('Error al parsear pagination: $e');
            print('Datos de pagination: $paginationData');
          }
        }
      } else {
        _error = response['error']?.toString() ?? 'Error desconocido';
      }
    } catch (e) {
      _error = 'Error al cargar historial: $e';
      print('Error completo en loadGameHistory: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para cambiar filtro sin recargar desde el servidor
  void changeFilter(String filter) {
    _currentFilter = filter;
    _applyClientSideFilter(filter);
    notifyListeners();
  }

  Future<void> loadMonthlyStats({int? year, int? month}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _historyService.getMonthlyStats(
        year: year,
        month: month,
      );

      if (response['success'] == true) {
        try {
          // Crear las estadísticas mensuales con corrección de zona horaria
          _monthlyStats = _processMonthlyStatsWithTimezoneCorrection(response);
        } catch (e) {
          print('Error al parsear monthly stats: $e');
          print('Datos de monthly stats: $response');
          _error = 'Error al procesar estadísticas mensuales';
        }
      } else {
        _error = response['error']?.toString() ?? 'Error desconocido';
      }
    } catch (e) {
      _error = 'Error al cargar estadísticas: $e';
      print('Error completo en loadMonthlyStats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Nuevo método para procesar estadísticas con corrección de zona horaria
  MonthlyStats _processMonthlyStatsWithTimezoneCorrection(Map<String, dynamic> response) {
    // Si el backend ya procesó las estadísticas correctamente, usar el resultado directo
    if (response['rawGames'] == null) {
      return MonthlyStats.fromJson(response);
    }

    // Si tenemos los juegos crudos, procesarlos con corrección de zona horaria
    final rawGames = response['rawGames'] as List;
    final Map<int, DailyStats> correctedDailyStats = {};
    int totalGames = 0;
    int totalWins = 0;

    // Usar un Map temporal para acumular los datos por día
    final Map<int, Map<String, dynamic>> tempDailyData = {};

    for (var gameData in rawGames) {
      if (gameData is Map<String, dynamic>) {
        try {
          // Parsear la fecha y ajustarla a zona horaria mexicana
          final completedAt = DateTime.parse(gameData['completedAt'] as String);
          final localDate = _adjustToMexicanTimezone(completedAt);
          final day = localDate.day;

          if (!tempDailyData.containsKey(day)) {
            tempDailyData[day] = {
              'games': 0,
              'wins': 0,
              'attempts': <int>[],
            };
          }

          tempDailyData[day]!['games'] = (tempDailyData[day]!['games'] as int) + 1;
          totalGames++;

          if (gameData['isWon'] == true) {
            tempDailyData[day]!['wins'] = (tempDailyData[day]!['wins'] as int) + 1;
            totalWins++;
            
            // Agregar intentos si está disponible
            final attemptsUsed = gameData['attemptsUsed'] ?? 
                                (6 - (gameData['attemptsLeft'] ?? 0));
            (tempDailyData[day]!['attempts'] as List<int>).add(attemptsUsed);
          }
        } catch (e) {
          print('Error procesando juego para estadísticas: $e');
        }
      }
    }

    // Convertir datos temporales a DailyStats
    for (final entry in tempDailyData.entries) {
      final day = entry.key;
      final data = entry.value;
      
      correctedDailyStats[day] = DailyStats(
        games: data['games'] as int,
        wins: data['wins'] as int,
        attempts: List<int>.from(data['attempts'] as List),
      );
    }

    return MonthlyStats(
      year: response['year'] ?? DateTime.now().year,
      month: response['month'] ?? DateTime.now().month,
      monthName: response['monthName'] ?? '',
      totalGames: totalGames,
      totalWins: totalWins,
      winRate: totalGames > 0 ? ((totalWins / totalGames) * 100).round() : 0,
      dailyStats: correctedDailyStats,
    );
  }

  Future<void> loadNextPage() async {
    if (_paginationInfo?.hasMore == true && !_isLoading) {
      await loadGameHistory(
        offset: _allGames.length, // Usar _allGames para paginación
        filter: _currentFilter,
        clearPrevious: false,
      );
    }
  }

  Future<void> refreshHistory() async {
    await loadGameHistory(clearPrevious: true, filter: _currentFilter);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}