import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/anime_model.dart';
import 'custom_loading_indicator.dart'; 

class AnimeCard extends StatelessWidget {
  final Anime anime;
  final VoidCallback? onTap;

  const AnimeCard({
    Key? key,
    required this.anime,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: Theme.of(context).cardTheme.shape,
        elevation: Theme.of(context).cardTheme.elevation ?? 4,
        child: GestureDetector(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildBackgroundImage(context),
              _buildGradientOverlay(),
              _buildTitleOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói a imagem de fundo com cache, tratamento de loading e erro.
  Widget _buildBackgroundImage(BuildContext context) {
    
    return CachedNetworkImage(
      imageUrl: anime.imagemCapa,
      fit: BoxFit.cover,
      // Widget mostrado enquanto a imagem está carregando
      // Widget mostrado enquanto a imagem está carregando
      placeholder: (context, url) => Container(
      color: Theme.of(context).cardTheme.color,
      // Usamos nosso indicador personalizado com um tamanho menor
        child: const CustomLoadingIndicator(width: 50, height: 50),
      ),
      // Widget mostrado se ocorrer um erro ao carregar a imagem
      errorWidget: (context, url, error) => Container(
        color: Theme.of(context).cardTheme.color,
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
          size: 50,
        ),
      ),
      // Animação de fade-in suave quando a imagem carrega
      fadeInDuration: const Duration(milliseconds: 300),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.1),
            Colors.black.withOpacity(0.8)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.5, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildTitleOverlay() {
    return Positioned(
      bottom: 12,
      left: 12,
      right: 12,
      child: Text(
        anime.nome,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
          height: 1.3,
          shadows: [
            Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 1)),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}