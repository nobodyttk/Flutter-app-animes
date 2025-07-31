

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile_model.dart';

class ProfileService {
  // Lembre-se de substituir pelo seu IP ou domínio. Ex: 'http://10.0.2.2:3037'
  static const String _baseUrl = 'https://localhost:3000/api';

  Future<UserProfileModel> fetchUserProfile(String userName, String token) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // Faz as duas requisições em paralelo para mais eficiência
      final responses = await Future.wait([
        http.get(Uri.parse('$_baseUrl/favoritos/$userName'), headers: headers),
        http.get(Uri.parse('$_baseUrl/completos/$userName'), headers: headers),
      ]);

      final favResponse = responses[0];
      final compResponse = responses[1];

      if (favResponse.statusCode == 200 && compResponse.statusCode == 200) {
        final favData = jsonDecode(favResponse.body);
        final compData = jsonDecode(compResponse.body);

        
        // Ele lida com toda a lógica de mapeamento e fallbacks internamente
        return UserProfileModel.fromJson(favData, compData);

      } else {
        // Log para ajudar a depurar em caso de erro
        print('Erro nos Favoritos: ${favResponse.statusCode} ${favResponse.body}');
        print('Erro nos Completos: ${compResponse.statusCode} ${compResponse.body}');
        throw Exception('Falha ao carregar dados do perfil (Status Code não foi 200).');
      }
    } catch (e) {
      print('Erro de conexão no ProfileService: $e');
      throw Exception('Erro de conexão ao buscar perfil.');
    }
  }
}