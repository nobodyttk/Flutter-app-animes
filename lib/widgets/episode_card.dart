// lib/widgets/episode_card.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:donghuahub_app/screens/video_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/episodio_model.dart';
import '../services/download_service.dart'; 
import 'custom_loading_indicator.dart';

class EpisodeCard extends StatelessWidget {
  final Episodio episodio;

  const EpisodeCard({Key? key, required this.episodio}) : super(key: key);

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
                            child: ElevatedButton(
                              child: Text('Assistir (${source.name})'),
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                                Navigator.of(context).push(MaterialPageRoute(builder: (_) => VideoPlayerScreen(videoUrl: source.url)));
                              },
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
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
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
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: () => _showPlayerOptions(context),
        borderRadius: BorderRadius.circular(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem no topo
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: CachedNetworkImage(
                imageUrl: episodio.imagemCapa,
                height: 100,
                width: 180,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 100,
                  width: 180,
                  color: Colors.grey.shade800,
                  child: const CustomLoadingIndicator(width: 50, height: 50),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 100,
                  width: 180,
                  color: Colors.grey.shade800,
                  child: const Icon(Icons.movie_creation_outlined, color: Colors.white54),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Textos embaixo
            Text(
              'Episódio ${episodio.numero}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              episodio.titulo,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}