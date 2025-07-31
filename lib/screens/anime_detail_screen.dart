// lib/screens/anime_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/anime_model.dart';
import '../services/anime_service.dart';
import '../providers/auth_provider.dart';

import '../widgets/episode_list_widget.dart';
import '../widgets/expandable_text_widget.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/custom_loading_indicator.dart';

import 'search_screen.dart';
import 'downloads_screen.dart';
import 'profile_screen.dart';

class AnimeDetailScreen extends StatefulWidget {
  final String slug;
  const AnimeDetailScreen({Key? key, required this.slug}) : super(key: key);

  @override
  State<AnimeDetailScreen> createState() => _AnimeDetailScreenState();
}

class _AnimeDetailScreenState extends State<AnimeDetailScreen> {
  late Future<Anime> _animeDetailsFuture;

  bool _isFavorito = false;
  bool _isCompleto = false;
  bool _isLoadingStatus = true;
  bool _didStateChange = false;

  @override
  void initState() {
    super.initState();
    _animeDetailsFuture = AnimeService.getAnimeDetails(widget.slug);
    _animeDetailsFuture.then((_) {
      _checkInitialStatus();
    });
  }

  Future<void> _checkInitialStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isLoggedIn) {
      if (mounted) setState(() => _isLoadingStatus = false);
      return;
    }

    try {
      final anime = await _animeDetailsFuture;
      final userId = authProvider.user!.id;
      final token = authProvider.token!;

      final results = await Future.wait([
        AnimeService.checkFavoriteStatus(userId, anime.id, token),
        AnimeService.checkCompleteStatus(userId, anime.id, token),
      ]);
      
      if (mounted) {
        setState(() {
          _isFavorito = results[0];
          _isCompleto = results[1];
          _isLoadingStatus = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingStatus = false);
      print("Erro ao verificar status: $e");
    }
  }

  Future<void> _handleFavoritoClick(Anime anime) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Você precisa estar logado para fazer isso.')));
      return;
    }
    
    final originalStatus = _isFavorito;
    setState(() => _isFavorito = !originalStatus);
    _didStateChange = true;
    
    try {
      await AnimeService.toggleFavorite(originalStatus, authProvider.user!.id, anime, authProvider.token!);
    } catch (e) {
      setState(() => _isFavorito = originalStatus);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: ${e.toString()}')));
    }
  }

  Future<void> _handleCompletoClick(Anime anime) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Você precisa estar logado para fazer isso.')));
      return;
    }
    
    final originalStatus = _isCompleto;
    setState(() => _isCompleto = !originalStatus);
    _didStateChange = true;
    
    try {
      await AnimeService.toggleComplete(originalStatus, authProvider.user!.id, anime, authProvider.token!);
    } catch (e) {
      setState(() => _isCompleto = originalStatus);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _didStateChange);
        return true;
      },
      child: Scaffold(
        body: FutureBuilder<Anime>(
          future: _animeDetailsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CustomLoadingIndicator();
            }
            if (snapshot.hasError) {
              return Center(child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Erro ao carregar detalhes.\n${snapshot.error}', textAlign: TextAlign.center),
              ));
            }
            if (snapshot.hasData) {
              final anime = snapshot.data!;
              return _buildSuccessUI(context, anime);
            }
            return const Center(child: Text('Nenhum dado encontrado.'));
          },
        ),
      ),
    );
  }

  Widget _buildSuccessUI(BuildContext context, Anime anime) {
    final textTheme = Theme.of(context).textTheme;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 400.0,
          pinned: true,
          stretch: true,
          elevation: 0,
          
          // Define a cor de fundo sólida para a barra quando recolhida.
          // Ela se adapta automaticamente ao tema claro/escuro.
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          
          leading: BackButton(onPressed: () => Navigator.pop(context, _didStateChange)),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen()));
              },
            ),
            IconButton(
              icon: const Icon(Icons.archive_outlined),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const DownloadsScreen()));
              },
            ),
            IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
              },
            ),
            const ThemeToggleButton(),
            const SizedBox(width: 8),
          ],
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              anime.nome,
              style: const TextStyle(fontSize: 16.0, shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
            ),
            // O background (com a imagem) é desenhado POR CIMA da cor de fundo,
            // então a cor sólida só aparece quando a barra está recolhida.
            background: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: anime.imagemSlide.isNotEmpty ? anime.imagemSlide : anime.imagemCapa,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const CustomLoadingIndicator(),
                  errorWidget: (context, url, error) => Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.white.withOpacity(0.5), size: 60)),
                  fadeInDuration: const Duration(milliseconds: 400),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.6), Colors.transparent, Colors.black.withOpacity(0.8)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(anime.nome, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: textTheme.bodySmall?.color),
                    const SizedBox(width: 4),
                    Text(anime.dataPublicacao.split('T')[0], style: textTheme.bodySmall),
                    const SizedBox(width: 16),
                    Icon(Icons.visibility, size: 14, color: textTheme.bodySmall?.color),
                    const SizedBox(width: 4),
                    Text('${anime.views} Views', style: textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: 16),
                if (authProvider.isLoggedIn) ...[
                  if (_isLoadingStatus)
                    const Center(child: Padding(padding: EdgeInsets.all(8.0), child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))))
                  else
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _handleFavoritoClick(anime),
                            icon: Icon(_isFavorito ? Icons.favorite : Icons.favorite_border),
                            label: Text(_isFavorito ? 'Favorito' : 'Favoritar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _isFavorito ? Colors.pink : Theme.of(context).textTheme.bodyLarge?.color,
                              side: BorderSide(color: _isFavorito ? Colors.pink : Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _handleCompletoClick(anime),
                            icon: Icon(_isCompleto ? Icons.check_circle : Icons.check_circle_outline),
                            label: Text(_isCompleto ? 'Completo' : 'Completar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _isCompleto ? Colors.green : Theme.of(context).textTheme.bodyLarge?.color,
                              side: BorderSide(color: _isCompleto ? Colors.green : Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                ],
                if (anime.generos.isNotEmpty) ...[
                  Text('Gêneros', style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0, runSpacing: 4.0,
                    children: anime.generos.map((g) => Chip(label: Text(g.nome))).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
                Text('Sinopse', style: textTheme.titleMedium),
                const SizedBox(height: 8),
                ExpandableTextWidget(
                  text: anime.sinopse,
                  trimLines: 4,
                ),
                const SizedBox(height: 24),
                if (anime.temporada != null)
                  EpisodeListWidget(
                    animeId: anime.id,
                    temporadaId: anime.temporada!.id,
                  )
                else
                  const SizedBox(
                    height: 140,
                    child: Center(child: Text('Informações de temporada não encontradas.')),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}