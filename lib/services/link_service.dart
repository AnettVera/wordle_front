import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class LinkService {
  static const String _baseUrl = 'https://wordle-render.onrender.com/api';

  // Genera un PIN de vinculación
  static Future<Map<String, dynamic>> generatePin() async {
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (idToken == null) {
      throw Exception('No autenticado');
    }
    final response = await http.post(
      Uri.parse('$_baseUrl/link/generate-pin'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al generar PIN: ${response.body}');
    }
  }

  // Verifica el estado de vinculación
  static Future<Map<String, dynamic>> checkLinkStatus() async {
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (idToken == null) {
      throw Exception('No autenticado');
    }
    final response = await http.get(
      Uri.parse('$_baseUrl/wordle?action=link-status'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al verificar estado: ${response.body}');
    }
  }
}
