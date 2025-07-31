// C:\Users\Windows\Desktop\piloto\piloto\lib\providers\genre_provider.dart

import 'package:flutter/material.dart';
import '../models/anime_model.dart';
import '../services/anime_service.dart';

class GenreProvider extends ChangeNotifier {
  List<Genero> _genres = [];
  bool _isLoading = false; // Começa como false
  String? _error;

  /// O construtor agora está vazio. A busca será chamada manualmente.
  GenreProvider(); // REMOVIDO fetchGenres() DAQUI

  // Getters públicos
  List<Genero> get genres => _genres;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Busca os gêneros da API e atualiza o estado.
  /// Retorna um Future para que a UI possa esperar (await).
  Future<void> fetchGenres() async {
    // Evita buscas múltiplas se já estiver carregando ou já tiver dados
    if (_isLoading || _genres.isNotEmpty) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final fetchedGenres = await AnimeService.getGeneros();
      _genres = fetchedGenres;
      
    } catch (e) {
      _error = "Falha ao carregar os gêneros. Tente novamente.";
      print("Erro ao buscar gêneros: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}