import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/downloaded_episode_model.dart';
import '../services/download_service.dart';
import 'video_player_screen.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Downloads'),
      ),
      body: Consumer<DownloadService>(
        builder: (context, downloadService, child) {
          final downloads = downloadService.downloadedEpisodes;

          if (downloads.isEmpty) {
            return const Center(
              child: Text(
                'Você ainda não baixou nenhum episódio.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            itemCount: downloads.length,
            itemBuilder: (context, index) {
              final downloadedEpisode = downloads[index];
              return _buildDownloadTile(context, downloadedEpisode, downloadService);
            },
          );
        },
      ),
    );
  }

  Widget _buildDownloadTile(BuildContext context, DownloadedEpisode episode, DownloadService service) {
    return ListTile(
      leading: CachedNetworkImage(
        imageUrl: episode.thumbnailUrl,
        width: 80,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => const Icon(Icons.image_not_supported),
      ),
      title: Text(episode.animeName, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('Episódio ${episode.episodeNumber}'),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
        onPressed: () {
          // Adicionar diálogo de confirmação
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Confirmar Exclusão'),
              content: const Text('Tem certeza que deseja apagar este episódio do seu dispositivo?'),
              actions: [
                TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.of(ctx).pop()),
                TextButton(
                  child: const Text('Apagar'),
                  onPressed: () {
                    service.deleteDownload(episode.episodeId);
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
          );
        },
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            // ATENÇÃO: Usando o construtor de arquivo local do player
            builder: (_) => VideoPlayerScreen(videoUrl: File(episode.filePath).uri.toString()),
          ),
        );
      },
    );
  }
}