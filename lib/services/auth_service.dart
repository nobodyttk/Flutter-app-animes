// lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {

  // Se estiver testando no emulador Android, use '10.0.2.2' para se referir ao localhost do seu computador.
  static const String _baseUrl = 'https://localhost:3000/auth';

  // Método para fazer login
  Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'senha': password,
      }),
    );

    if (response.statusCode == 200) {
      // Extrai o token da resposta
      return jsonDecode(response.body)['token'];
    } else {
      // Lança um erro com a mensagem da API
      throw Exception(jsonDecode(response.body)['message'] ?? 'Falha no login');
    }
  }

  // Método para registrar um novo usuário
  Future<String> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'nome': name,
        'email': email,
        'senha': password,
        'is_admin': false, // Por padrão, novos usuários não são admins
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body)['message'];
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Falha ao registrar');
    }
  }
}