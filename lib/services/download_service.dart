// lib/services/download_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/episodio_model.dart';
import '../models/downloaded_episode_model.dart';

class DownloadService extends ChangeNotifier {
  final Dio _dio = Dio();
  List<DownloadedEpisode> _downloadedEpisodes = [];
  final Map<String, double> _downloadProgress = {};

  
  final Map<String, CancelToken> _cancelTokens = {};

  // Getters públicos para a UI
  List<DownloadedEpisode> get downloadedEpisodes => _downloadedEpisodes;
  double getProgress(String episodeId) => _downloadProgress[episodeId] ?? 0.0;
  bool isDownloading(String episodeId) => _downloadProgress.containsKey(episodeId);

  DownloadService() {
    loadDownloadedEpisodes();
  }

  String? _getDownloadUrl(Episodio episodio) {
    try {
      final videoSource = episodio.videoSources.firstWhere(
        (source) => Uri.parse(source.url).queryParameters.containsKey('itemId'),
      );
      final uri = Uri.parse(videoSource.url);
      final itemId = uri.queryParameters['itemId'];
      if (itemId != null && itemId.isNotEmpty) {
        return 'https://localhost:3000/?itemId=$itemId';
      }
      return null;
    } catch (e) {
      print('Nenhuma fonte de download válida encontrada para o episódio ${episodio.id}');
      return null;
    }
  }

  Future<void> startDownload(Episodio episodio) async {
    final downloadUrl = _getDownloadUrl(episodio);
    if (downloadUrl == null) {
      throw Exception('Não foi possível obter um link de download válido.');
    }

    final episodeId = episodio.id.toString();
    if (isDownloading(episodeId)) return;
    if (_downloadedEpisodes.any((e) => e.episodeId == episodeId)) {
      throw Exception('Este episódio já foi baixado.');
    }

    final appDir = await getApplicationDocumentsDirectory();
    final filePath = '${appDir.path}/${episodio.slug}_ep${episodio.numero}.mp4';

    
    final cancelToken = CancelToken();
    _cancelTokens[episodeId] = cancelToken;

    _downloadProgress[episodeId] = 0.0;
    notifyListeners();

    try {
      await _dio.download(
        downloadUrl,
        filePath,
        cancelToken: cancelToken, 
        onReceiveProgress: (received, total) {
          if (total != -1) {
            _downloadProgress[episodeId] = received / total;
            notifyListeners();
          }
        },
      );

      // Se chegar aqui, o download foi concluído com sucesso
      final newDownload = DownloadedEpisode(
        episodeId: episodeId,
        animeName: episodio.titulo,
        episodeNumber: episodio.numero,
        thumbnailUrl: episodio.imagemCapa,
        filePath: filePath,
      );
      _downloadedEpisodes.add(newDownload);
      await _saveToPrefs();

    } on DioException catch (e) {
      // Se o erro foi por cancelamento, não mostre uma mensagem de falha
      if (e.type == DioExceptionType.cancel) {
        print('Download do episódio $episodeId cancelado pelo usuário.');
      } else {
        print("Erro no download: $e");
        throw Exception('Falha no download. Verifique a conexão ou tente novamente.');
      }
      // Limpa o arquivo parcial em caso de erro ou cancelamento
      final file = File(filePath);
      if(await file.exists()) {
        await file.delete();
      }
    } finally {
      _downloadProgress.remove(episodeId);
      _cancelTokens.remove(episodeId); // Remove o token ao finalizar
      notifyListeners();
    }
  }
  
  
  Future<void> cancelDownload(String episodeId) async {
    // Encontra o token e chama o método de cancelamento do Dio
    if (_cancelTokens.containsKey(episodeId)) {
      _cancelTokens[episodeId]?.cancel(); // Isso vai disparar o 'catch' no método startDownload
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> downloadsJson = _downloadedEpisodes.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('downloaded_episodes', downloadsJson);
  }

  Future<void> loadDownloadedEpisodes() async {
    final prefs = await SharedPreferences.getInstance();
    final downloadsJson = prefs.getStringList('downloaded_episodes') ?? [];
    _downloadedEpisodes = downloadsJson.map((jsonString) => DownloadedEpisode.fromJson(jsonDecode(jsonString))).toList();
    notifyListeners();
  }

  Future<void> deleteDownload(String episodeId) async {
    try {
      final downloadToDelete = _downloadedEpisodes.firstWhere((e) => e.episodeId == episodeId);
      final file = File(downloadToDelete.filePath);
      if (await file.exists()) {
        await file.delete();
      }
      _downloadedEpisodes.removeWhere((e) => e.episodeId == episodeId);
      await _saveToPrefs();
      notifyListeners();
    } catch (e) {
      print('Erro ao deletar o episódio $episodeId: $e');
    }
  }
}