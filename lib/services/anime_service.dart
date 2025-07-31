// lib/services/anime_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/anime_model.dart';
import '../models/episodio_model.dart';
import '../models/filtered_animes_response.dart';

class AnimeService {
  // A base da sua API
  static const String baseUrl = 'https://localhost:3000';

  static Future<List<Genero>> getGeneros() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/animes/generos'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((json) => Genero.fromJson(json))
            .where((genero) => genero.nome.trim().isNotEmpty)
            .toList();
      } else {
        throw Exception('Falha ao carregar gêneros: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição de gêneros: $e');
    }
  }

  static Future<FilteredAnimesResponse> getAnimesByGenre(String genreName, {int page = 1}) async {
    try {
      final encodedGenre = Uri.encodeComponent(genreName.toLowerCase());
      final response = await http.get(
        Uri.parse('$baseUrl/api/animes/filter/$encodedGenre?page=$page'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return FilteredAnimesResponse.fromJson(jsonData);
      } else {
        throw Exception('Falha ao filtrar animes por gênero: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição de filtro por gênero: $e');
    }
  }

  static Future<List<Anime>> getAnimesRecentes({int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/animes/recentes?page=$page'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Anime.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar animes recentes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição de recentes: $e');
    }
  }

  static Future<Anime> getAnimeDetails(String slug) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/animes/$slug'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Anime.fromJson(jsonData);
      } else {
        throw Exception('Falha ao carregar detalhes do anime: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição de detalhes: $e');
    }
  }

  static Future<List<Episodio>> getEpisodios(int animeId, int temporadaId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/episodios/$animeId/$temporadaId'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Episodio.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar episódios: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição de episódios: $e');
    }
  }

  static Future<List<Anime>> searchAnimes(String query, {int? limit}) async {
    if (query.trim().isEmpty) {
      return [];
    }
    try {
      final encodedQuery = Uri.encodeComponent(query);
      String url = '$baseUrl/api/animes/search?query=$encodedQuery';
      if (limit != null) {
        url += '&limit=$limit';
      }
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Anime.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao buscar animes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição de busca: $e');
    }
  }

  static Future<List<Anime>> getSliderAnimes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/slide'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Anime.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar os slides: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição dos slides: $e');
    }
  }

  static Future<List<Episodio>> getEpisodiosRecentes({int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/episodios/paginacaoep?page=$page'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> episodiosData = jsonData['episodios'];
        return episodiosData.map((json) => Episodio.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar episódios recentes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição de episódios recentes: $e');
    }
  }
  
  // -- MÉTODOS DE FAVORITOS E COMPLETOS (TODOS STATIC) --

  static Future<bool> _checkStatus(String type, int userId, int animeId, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/$type/check/$userId/$animeId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)[type == 'favoritos' ? 'isFavorito' : 'isCompleto'] ?? false;
    }
    return false;
  }

  static Future<void> _addItem(String type, int userId, Anime anime, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/$type'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'usuario_id': userId,
        'anime_id': anime.id,
        'nome': anime.nome,
        'imagem': anime.imagemCapa,
        'slug': anime.slug,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Falha ao adicionar aos $type.');
    }
  }

  static Future<void> _removeItem(String type, int userId, int animeId, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/$type'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'usuario_id': userId,
        'anime_id': animeId,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Falha ao remover dos $type.');
    }
  }

  static Future<bool> checkFavoriteStatus(int userId, int animeId, String token) => 
      _checkStatus('favoritos', userId, animeId, token);

  static Future<bool> checkCompleteStatus(int userId, int animeId, String token) => 
      _checkStatus('completos', userId, animeId, token);

  static Future<void> toggleFavorite(bool isCurrentlyFavorite, int userId, Anime anime, String token) {
    if (isCurrentlyFavorite) {
      return _removeItem('favoritos', userId, anime.id, token);
    } else {
      return _addItem('favoritos', userId, anime, token);
    }
  }

  static Future<void> toggleComplete(bool isCurrentlyComplete, int userId, Anime anime, String token) {
    if (isCurrentlyComplete) {
      return _removeItem('completos', userId, anime.id, token);
    } else {
      return _addItem('completos', userId, anime, token);
    }
  }
    // ==========================================================
  
  // ==========================================================
  static Future<List<Anime>> getMaisVisualizadosAnimes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/animes/mais-visualizados'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Anime.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar animes mais visualizados: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição de mais visualizados: $e');
    }
  }
}