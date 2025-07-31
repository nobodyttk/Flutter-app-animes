import 'anime_model.dart';

// Modelo para a resposta completa da API de filtro
class FilteredAnimesResponse {
  final List<Anime> animes;
  final int totalPages;
  final int currentPage;

  FilteredAnimesResponse({
    required this.animes,
    required this.totalPages,
    required this.currentPage,
  });

  factory FilteredAnimesResponse.fromJson(Map<String, dynamic> json) {
    // Converte a lista de JSONs de animes em uma lista de objetos Anime
    var animesList = <Anime>[];
    if (json['animes'] != null && json['animes'] is List) {
      animesList = (json['animes'] as List)
          .map((a) => Anime.fromJson(a))
          .toList();
    }

    return FilteredAnimesResponse(
      animes: animesList,
      totalPages: json['totalPages'] ?? 1,
      currentPage: json['currentPage'] ?? 1,
    );
  }
}