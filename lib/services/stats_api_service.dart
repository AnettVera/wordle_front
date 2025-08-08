// services/stats_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class StatsApiService {
  static const String baseUrl = 'https://wordle-render.onrender.com'; // Reemplaza con tu URL real
  
  // Obtener headers con token de Firebase Auth
  static Future<Map<String, String>> _getAuthHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final token = await user.getIdToken();
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    }
    return {'Content-Type': 'application/json'};
  }
  
  // Obtener estadísticas del usuario
  static Future<StatsResponse> getUserStats() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/wordle?action=stats'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return StatsResponse.fromJson(data);
      } else {
        throw Exception('Error al obtener estadísticas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}

// Modelos para las estadísticas
class StatsResponse {
  final bool success;
  final UserStats? stats;
  final String? error;

  StatsResponse({
    required this.success,
    this.stats,
    this.error,
  });

  factory StatsResponse.fromJson(Map<String, dynamic> json) {
    return StatsResponse(
      success: json['success'] ?? false,
      stats: json['stats'] != null ? UserStats.fromJson(json['stats']) : null,
      error: json['error'],
    );
  }
}

class UserStats {
  final int totalGames;
  final int wins;
  final int losses;
  final int winPercentage;
  final int currentStreak;
  final int maxStreak;
  final List<int> attemptDistribution;
  final double averageAttempts;
  final String effectiveUid;
  final bool isLinked;

  UserStats({
    required this.totalGames,
    required this.wins,
    required this.losses,
    required this.winPercentage,
    required this.currentStreak,
    required this.maxStreak,
    required this.attemptDistribution,
    required this.averageAttempts,
    required this.effectiveUid,
    required this.isLinked,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalGames: json['totalGames'] ?? 0,
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
      winPercentage: json['winPercentage'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      maxStreak: json['maxStreak'] ?? 0,
      attemptDistribution: List<int>.from(json['attemptDistribution'] ?? [0, 0, 0, 0, 0, 0]),
      averageAttempts: (json['averageAttempts'] ?? 0.0).toDouble(),
      effectiveUid: json['effectiveUid'] ?? '',
      isLinked: json['isLinked'] ?? false,
    );
  }
}