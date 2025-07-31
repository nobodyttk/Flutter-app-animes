import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import '../providers/genre_provider.dart'; 
import '../models/anime_model.dart';
import '../services/anime_service.dart';
import '../widgets/search_result_tile.dart';
import '../widgets/custom_loading_indicator.dart'; 

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  List<Anime> _results = [];
  bool _isLoading = false;
  String _currentSearchQuery = '';

  // List<Genero> _genres = []; (REMOVIDO)
  // bool _isLoadingGenres = true; (REMOVIDO)
  Genero? _selectedGenre;

  final _scrollController = ScrollController();
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
    
   
    // _loadAllGenres(); (REMOVIDO)
    _loadInitialResults();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  
  // Future<void> _loadAllGenres() async { ... } (REMOVIDO)

  // ... (O resto dos métodos de lógica como _onSearchChanged, _performSearch, etc. permanecem os mesmos)
  Future<void> _loadInitialResults() async {
    setState(() => _isLoading = true);
    try {
      final results = await AnimeService.searchAnimes('a', limit: 10);
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      if (query.isNotEmpty && query != _currentSearchQuery) {
        if (_selectedGenre != null) {
          setState(() => _selectedGenre = null);
        }
        _performSearch(query);
      } else if (query.isEmpty && _currentSearchQuery.isNotEmpty) {
        _currentSearchQuery = '';
        _loadInitialResults();
      }
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      _currentSearchQuery = query;
      _results = [];
    });
    try {
      final results = await AnimeService.searchAnimes(query);
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onGenreSelected(Genero genre) {
    if (_selectedGenre?.id == genre.id) {
      setState(() {
        _selectedGenre = null;
        _results = [];
      });
      _loadInitialResults();
      return;
    }
    
    _searchController.clear();
    _currentSearchQuery = '';
    
    setState(() {
      _selectedGenre = genre;
      _isLoading = true;
      _results = [];
      _currentPage = 1;
    });

    _loadAnimesByGenre();
  }

  Future<void> _loadAnimesByGenre({bool isPaginating = false}) async {
    if (_selectedGenre == null) return;

    if (isPaginating) {
      setState(() => _isLoadingMore = true);
    }

    try {
      final response = await AnimeService.getAnimesByGenre(
        _selectedGenre!.nome,
        page: _currentPage,
      );
      if (mounted) {
        setState(() {
          if (isPaginating) {
            _results.addAll(response.animes);
          } else {
            _results = response.animes;
          }
          _totalPages = response.totalPages;
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _onScroll() {
    if (_selectedGenre != null) {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore &&
          _currentPage < _totalPages) {
        _currentPage++;
        _loadAnimesByGenre(isPaginating: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Buscar animes ou filtrar por gênero...',
            border: InputBorder.none,
          ),
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGenreFilterBar(), // Este método será modificado
          const Divider(height: 1),
          Expanded(child: _buildBodyContent()),
        ],
      ),
    );
  }

  /// Constrói a barra de filtros usando os dados do GenreProvider.
  Widget _buildGenreFilterBar() {
    // 👇 6. Consuma o GenreProvider para obter o estado e os dados
    return Consumer<GenreProvider>(
      builder: (context, genreProvider, child) {
        if (genreProvider.isLoading) {
          return const SizedBox(height: 50, child: Center(child: CircularProgressIndicator()));
        }

        if (genreProvider.error != null) {
          return SizedBox(
            height: 50,
            child: Center(child: Text(genreProvider.error!, style: TextStyle(color: Colors.red))),
          );
        }

        if (genreProvider.genres.isEmpty) {
          return const SizedBox.shrink(); // Não mostra nada se a lista estiver vazia
        }

        // Se tudo estiver OK, constrói a lista de chips
        return SizedBox(
          height: 50,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            scrollDirection: Axis.horizontal,
            itemCount: genreProvider.genres.length,
            itemBuilder: (context, index) {
              final genre = genreProvider.genres[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: FilterChip(
                  label: Text(genre.nome),
                  selected: _selectedGenre?.id == genre.id,
                  onSelected: (_) => _onGenreSelected(genre),
                  selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  showCheckmark: false,
                ),
              );
            },
          ),
        );
      },
    );
  }
  
  Widget _buildBodyContent() {
   if (_isLoading) {
  return const CustomLoadingIndicator(); // <-- LINHA NOVA
}
    if (_results.isEmpty) {
      return Center(
        child: Text(
          _currentSearchQuery.isNotEmpty || _selectedGenre != null
              ? 'Nenhum resultado encontrado.'
              : 'Comece a digitar para buscar ou selecione um gênero.',
        ),
      );
    }
    
    return ListView.builder(
      controller: _scrollController,
      itemCount: _results.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
      if (index == _results.length && _isLoadingMore) {
  return const CustomLoadingIndicator(height: 80); // <-- LINHA NOVA, menor
}
        return SearchResultTile(anime: _results[index]);
      },
    );
  }
}