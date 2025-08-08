import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/letter_feedback.dart';

class WordleApiService {
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
  
  // Obtener juego actual
  static Future<GameResponse> getCurrentGame() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/wordle?action=current'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return GameResponse.fromJson(data);
      } else {
        throw Exception('Error al obtener el juego: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Reiniciar juego
  static Future<GameResponse> resetGame() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/wordle'),
        headers: headers,
        body: json.encode({'action': 'reset'}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return GameResponse.fromJson(data);
      } else {
        throw Exception('Error al reiniciar el juego: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

}

// Modelos de datos
class GameResponse {
  final bool success;
  final Game? game;
  final String? error;
  final String? message;

  GameResponse({
    required this.success,
    this.game,
    this.error,
    this.message,
  });

  factory GameResponse.fromJson(Map<String, dynamic> json) {
    return GameResponse(
      success: json['success'] ?? false,
      game: json['game'] != null ? Game.fromJson(json['game']) : null,
      error: json['error'],
      message: json['message'],
    );
  }
}

class Game {
  final String uid;
  final String? alexaUserId;
  final List<Attempt> attempts;
  final int attemptsLeft;
  final bool isWon;
  final bool isLost;
  final String? targetWord;
  final String gameStatus;
  final String message;
  final bool isLinkedToAlexa;
  final int totalAttempts;
  final int usedAttempts;
  final int remainingAttempts;

  Game({
    required this.uid,
    this.alexaUserId,
    required this.attempts,
    required this.attemptsLeft,
    required this.isWon,
    required this.isLost,
    this.targetWord,
    required this.gameStatus,
    required this.message,
    required this.isLinkedToAlexa,
    required this.totalAttempts,
    required this.usedAttempts,
    required this.remainingAttempts,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      uid: json['uid'] ?? '',
      alexaUserId: json['alexaUserId'],
      attempts: (json['attempts'] as List<dynamic>? ?? [])
          .map((attempt) => Attempt.fromJson(attempt))
          .toList(),
      attemptsLeft: json['attemptsLeft'] ?? 0,
      isWon: json['isWon'] ?? false,
      isLost: json['isLost'] ?? false,
      targetWord: json['targetWord'],
      gameStatus: json['gameStatus'] ?? 'playing',
      message: json['message'] ?? '',
      isLinkedToAlexa: json['isLinkedToAlexa'] ?? false,
      totalAttempts: json['totalAttempts'] ?? 6,
      usedAttempts: json['usedAttempts'] ?? 0,
      remainingAttempts: json['remainingAttempts'] ?? 0,
    );
  }
}

class Attempt {
  final String guess;
  final List<LetterFeedback> feedback;

  Attempt({
    required this.guess,
    required this.feedback,
  });

  factory Attempt.fromJson(Map<String, dynamic> json) {
    return Attempt(
      guess: json['guess'] ?? '',
      feedback: (json['feedback'] as List<dynamic>? ?? [])
          .map((fb) => LetterFeedback.fromJson(fb))
          .toList(),
    );
  }
}

// Modelos de datos adicionales para vinculación
class PinResponse {
  final bool success;
  final String? pin;
  final String? error;
  final String? message;

  PinResponse({
    required this.success,
    this.pin,
    this.error,
    this.message,
  });

  factory PinResponse.fromJson(Map<String, dynamic> json) {
    return PinResponse(
      success: json['success'] ?? false,
      pin: json['pin'],
      error: json['error'],
      message: json['message'],
    );
  }
}

class LinkStatusResponse {
  final bool success;
  final bool isLinked;
  final String? alexaUserId;
  final String? error;

  LinkStatusResponse({
    required this.success,
    required this.isLinked,
    this.alexaUserId,
    this.error,
  });

  factory LinkStatusResponse.fromJson(Map<String, dynamic> json) {
    return LinkStatusResponse(
      success: json['success'] ?? false,
      isLinked: json['isLinked'] ?? false,
      alexaUserId: json['alexaUserId'],
      error: json['error'],
    );
  }
}

class UnlinkResponse {
  final bool success;
  final String? message;
  final String? error;

  UnlinkResponse({
    required this.success,
    this.message,
    this.error,
  });

  factory UnlinkResponse.fromJson(Map<String, dynamic> json) {
    return UnlinkResponse(
      success: json['success'] ?? false,
      message: json['message'],
      error: json['error'],
    );
  }
}