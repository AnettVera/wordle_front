// providers/stats_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/stats_api_service.dart';

class StatsProvider extends ChangeNotifier {
  UserStats? _userStats;
  bool _isLoading = false;
  String? _error;

  UserStats? get userStats => _userStats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Verificar si el usuario está autenticado
  bool get isAuthenticated => FirebaseAuth.instance.currentUser != null;

  // Obtener estadísticas del usuario
  Future<void> fetchUserStats() async {
    if (!isAuthenticated) {
      _error = 'Usuario no autenticado';
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      final response = await StatsApiService.getUserStats();
      if (response.success && response.stats != null) {
        _userStats = response.stats;
        _error = null;
      } else {
        _error = response.error ?? 'Error al obtener estadísticas';
        _userStats = null;
      }
    } catch (e) {
      _error = e.toString();
      _userStats = null;
    } finally {
      _setLoading(false);
    }
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Obtener el porcentaje para cada intento en la distribución
  List<double> getAttemptDistributionPercentages() {
    if (_userStats == null || _userStats!.wins == 0) {
      return [0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
    }

    return _userStats!.attemptDistribution
        .map((count) => (count / _userStats!.wins) * 100)
        .toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}