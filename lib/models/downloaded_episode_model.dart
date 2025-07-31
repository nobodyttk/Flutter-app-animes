// lib/models/downloaded_episode_model.dart

class DownloadedEpisode {
  final String episodeId;
  final String animeName;
  final int episodeNumber;
  final String thumbnailUrl;
  final String filePath; // Caminho para o arquivo de vídeo no dispositivo

  DownloadedEpisode({
    required this.episodeId,
    required this.animeName,
    required this.episodeNumber,
    required this.thumbnailUrl,
    required this.filePath,
  });

  // Métodos para converter para/de JSON, para que possamos salvar a lista facilmente
  factory DownloadedEpisode.fromJson(Map<String, dynamic> json) {
    return DownloadedEpisode(
      episodeId: json['episodeId'],
      animeName: json['animeName'],
      episodeNumber: json['episodeNumber'],
      thumbnailUrl: json['thumbnailUrl'],
      filePath: json['filePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'episodeId': episodeId,
      'animeName': animeName,
      'episodeNumber': episodeNumber,
      'thumbnailUrl': thumbnailUrl,
      'filePath': filePath,
    };
  }
}