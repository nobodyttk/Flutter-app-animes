// lib/widgets/episode_list_widget.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/episodio_model.dart';
import '../services/anime_service.dart';
import '../services/download_service.dart';
import '../screens/video_player_screen.dart';
import 'custom_loading_indicator.dart';

enum SortOrder { recentes, antigos }

class EpisodeListWidget extends StatefulWidget {
  final int animeId;
  final int temporadaId;

  const EpisodeListWidget({
    Key? key,
    required this.animeId,
    required this.temporadaId,
  }) : super(key: key);

  @override
  State<EpisodeListWidget> createState() => _EpisodeListWidgetState();
}

class _EpisodeListWidgetState extends State<EpisodeListWidget> {
  late Future<List<Episodio>> _episodiosFuture;
  SortOrder _currentSortOrder = SortOrder.recentes;

  final List<Episodio> _allEpisodes = [];
  final List<Episodio> _visibleEpisodes = [];
  int _currentPage = 1;
  int _totalPages = 1;
  final int _episodesPerPage = 30;

  @override
  void initState() {
    super.initState();
    _episodiosFuture = AnimeService.getEpisodios(widget.animeId, widget.temporadaId);
  }

  void _updateVisibleEpisodes() {
    _allEpisodes.sort((a, b) {
      if (_currentSortOrder == SortOrder.recentes) {
        return b.numero.compareTo(a.numero);
      } else {
        return a.numero.compareTo(b.numero);
      }
    });

    setState(() {
      _totalPages = (_allEpisodes.length / _episodesPerPage).ceil();
      if (_totalPages == 0) _totalPages = 1;

      final startIndex = (_currentPage - 1) * _episodesPerPage;
      int endIndex = startIndex + _episodesPerPage;
      if (endIndex > _allEpisodes.length) {
        endIndex = _allEpisodes.length;
      }

      _visibleEpisodes.clear();
      if (startIndex < _allEpisodes.length) {
        _visibleEpisodes.addAll(_allEpisodes.getRange(startIndex, endIndex));
      }
    });
  }

  Widget _buildPaginationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          icon: const Icon(Icons.arrow_back_ios, size: 16),
          label: const Text('Anterior'),
          onPressed: _currentPage > 1
              ? () {
                  setState(() => _currentPage--);
                  _updateVisibleEpisodes();
                }
              : null,
        ),
        Text('Página $_currentPage de $_totalPages'),
        TextButton.icon(
          label: const Icon(Icons.arrow_forward_ios, size: 16),
          icon: const Text('Próximo'),
          onPressed: _currentPage < _totalPages
              ? () {
                  setState(() => _currentPage++);
                  _updateVisibleEpisodes();
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildSortButton() {
    final bool isRecentes = _currentSortOrder == SortOrder.recentes;
    final String text = isRecentes ? 'Antigos' : 'Recentes';
    final IconData icon = isRecentes ? Icons.arrow_upward : Icons.arrow_downward;

    return TextButton.icon(
      onPressed: () {
        setState(() {
          _currentSortOrder = isRecentes ? SortOrder.antigos : SortOrder.recentes;
          _currentPage = 1;
        });
        _updateVisibleEpisodes();
      },
      icon: Icon(icon, size: 20),
      label: Text(text),
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        alignment: Alignment.centerRight,
      ),
    );
  }

  void _showOptionsDialog(BuildContext context, Episodio episodio) {
    final sources = episodio.videoSources;
    if (sources.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum vídeo disponível para este episódio.')),
      );
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
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
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => downloadService.cancelDownload(episodeId),
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
                              downloadService.startDownload(episodio).catchError((e) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                              });
                            },
                          ),
                  ],
                ),
              ),
              actions: <Widget>[
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
    return FutureBuilder<List<Episodio>>(
      future: _episodiosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 200, child: CustomLoadingIndicator());
        }
        if (snapshot.hasError) {
          return SizedBox(height: 200, child: Center(child: Text('Erro ao carregar episódios.')));
        }
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          if (_allEpisodes.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _allEpisodes.addAll(snapshot.data!);
                _updateVisibleEpisodes();
              }
            });
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Episódios', style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  _buildSortButton(),
                ],
              ),
              const SizedBox(height: 8),
              ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _visibleEpisodes.length,
                itemBuilder: (context, index) {
                  final episodio = _visibleEpisodes[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: CachedNetworkImage(
                          imageUrl: episodio.imagemCapa,
                          width: 80, height: 60, fit: BoxFit.cover,
                          errorWidget: (context, url, error) => const Icon(Icons.image_not_supported),
                        ),
                      ),
                      title: Text('Episódio ${episodio.numero}'),
                      subtitle: Text(episodio.titulo, maxLines: 1, overflow: TextOverflow.ellipsis),
                      onTap: () => _showOptionsDialog(context, episodio),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              if (_totalPages > 1) _buildPaginationControls(),
            ],
          );
        }
        return const SizedBox(height: 150, child: Center(child: Text('Nenhum episódio encontrado.')));
      },
    );
  }
}