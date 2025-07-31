// lib/widgets/episode_home_card.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import '../models/episodio_model.dart';
import '../screens/video_player_screen.dart';
import '../services/download_service.dart'; 
import 'custom_loading_indicator.dart';

class EpisodeHomeCard extends StatelessWidget {
  final Episodio episodio;

  const EpisodeHomeCard({Key? key, required this.episodio}) : super(key: key);

  void _showPlayerOptions(BuildContext context) {
    final sources = episodio.videoSources;
    if (sources.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum vídeo disponível para este episódio.')),
      );
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false, // Impede que o diálogo feche ao clicar fora durante o download
      builder: (BuildContext dialogContext) {
        return Consumer<DownloadService>(
          builder: (context, downloadService, child) {
            final episodeId = episodio.id.toString();
            final isDownloading = downloadService.isDownloading(episodeId);
            final progress = downloadService.getProgress(episodeId);

            return AlertDialog(
              title: Text('Episódio ${episodio.numero}'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Escolha uma opção:'),
                    const SizedBox(height: 16),
                    // Botões de Player (só mostra se não estiver baixando)
                    if (!isDownloading) ...[
                      ...sources.map((source) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                           child: OutlinedButton(
                          child: Text('Assistir (${source.name})'),
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => VideoPlayerScreen(videoUrl: source.url)));
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white, // Cor do texto
                            side: BorderSide(color: Colors.white.withOpacity(0.5)), // Cor da borda
                          ),
                        ),
                      )),
                      const SizedBox(height: 8),
                    ],
                    // Botão de Download ou Barra de Progresso
                    isDownloading
                        ? Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      LinearProgressIndicator(value: progress, backgroundColor: Colors.grey.shade700),
                                      const SizedBox(height: 4),
                                      Text('Baixando... ${(progress * 100).toStringAsFixed(0)}%'),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // O BOTÃO DE CANCELAR
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    downloadService.cancelDownload(episodeId);
                                  },
                                )
                              ],
                            ),
                          )
                        : ElevatedButton.icon(
                            icon: const Icon(Icons.download),
                            label: const Text('Baixar Episódio'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green, // Cor de fundo
                              foregroundColor: Colors.white, // Cor do texto e do ícone
                            ),
                            onPressed: () {
                              downloadService.startDownload(episodio).then((_) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Download iniciado!')));
                              }).catchError((e) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                              });
                            },
                          ),
                  ],
                ),
              ),
              actions: <Widget>[
                // Só mostra o botão de fechar se não estiver baixando
                if (!isDownloading)
                  TextButton(
                    child: const Text('Fechar'),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: () => _showPlayerOptions(context),
        borderRadius: BorderRadius.circular(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- PARTE VISUAL COM A IMAGEM ---
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Stack(
                children: [
                  // CAMADA 1: A IMAGEM
                  CachedNetworkImage(
                    imageUrl: episodio.imagemCapa,
                    height: 100,
                    width: 160,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 100,
                      width: 160,
                      color: Colors.grey.shade800,
                      child: const CustomLoadingIndicator(width: 50, height: 50),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 100,
                      width: 160,
                      color: Colors.grey.shade800,
                      child: const Icon(Icons.movie_creation_outlined, color: Colors.white54),
                    ),
                  ),

                  // CAMADA 2: O GRADIENTE ESCURO PARA LEGIBILIDADE
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.0),
                            Colors.black.withOpacity(0.8)
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.4, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // CAMADA 3: O TÍTULO DO ANIME NA PARTE DE BAIXO
                  Positioned(
                    bottom: 8.0,
                    left: 8.0,
                    right: 8.0,
                    child: Text(
                      episodio.titulo, // O título do episódio na API é o nome do anime
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // CAMADA 4: O BADGE COM O NÚMERO DO EPISÓDIO
                  Positioned(
                    top: 8.0,
                    right: 8.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(6.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        episodio.numero.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}