// lib/services/history_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class HistoryService {
  static const String baseUrl = 'https://wordle-render.onrender.com';
  
  // Obtener headers con token de Firebase Auth (igual que StatsApiService)
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

  Future<Map<String, dynamic>> getGameHistory({
    int limit = 50,
    int offset = 0,
    String sortBy = 'completedAt',
    String sortOrder = 'desc',
    String filter = 'all',
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      // Verificar que el usuario esté autenticado
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return {'success': false, 'error': 'Usuario no autenticado'};
      }

      final headers = await _getAuthHeaders();
      
      final queryParams = <String, String>{
        'action': 'history',
        'limit': limit.toString(),
        'offset': offset.toString(),
        'sortBy': sortBy,
        'sortOrder': sortOrder,
        'filter': filter,
      };

      if (dateFrom != null) queryParams['dateFrom'] = dateFrom;
      if (dateTo != null) queryParams['dateTo'] = dateTo;

      final uri = Uri.parse('$baseUrl/api/wordle').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'error': 'Error del servidor: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }

  Future<Map<String, dynamic>> getMonthlyStats({
    int? year,
    int? month,
  }) async {
    try {
      // Verificar que el usuario esté autenticado
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return {'success': false, 'error': 'Usuario no autenticado'};
      }

      final headers = await _getAuthHeaders();

      final queryParams = <String, String>{
        'action': 'monthly-stats',
      };

      if (year != null) queryParams['year'] = year.toString();
      if (month != null) queryParams['month'] = month.toString();

      final uri = Uri.parse('$baseUrl/api/wordle').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'error': 'Error del servidor: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }
}