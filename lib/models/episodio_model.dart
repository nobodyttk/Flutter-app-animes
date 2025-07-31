// C:\Users\Windows\Desktop\piloto\piloto\lib\models\episodio_model.dart
// Classe auxiliar para representar uma fonte de vídeo
class VideoSource {
  final String name; // Ex: "Player Principal"
  final String url;  // Ex: "https://..."

  VideoSource({required this.name, required this.url});
}

class Episodio {
  final int id;
  final int numero;
  final String titulo;
  final String descricao;
  final String imagemCapa;
  final String linksVideo; // Esta propriedade nunca será nula
  final int views;
  final String slug;

  Episodio({
    required this.id,
    required this.numero,
    required this.titulo,
    required this.descricao,
    required this.imagemCapa,
    required this.linksVideo,
    required this.views,
    required this.slug,
  });

  factory Episodio.fromJson(Map<String, dynamic> json) {
    return Episodio(
      id: json['id'] ?? 0,
      numero: json['numero'] ?? 0,
      titulo: json['titulo'] ?? 'Título indisponível',
      descricao: json['descricao'] ?? '',
      imagemCapa: json['imagem_capa'] ?? '',
      // Usamos o operador '??' para fornecer um valor padrão ('') se 'links_video' for nulo.
      linksVideo: json['links_video'] ?? '',
      views: json['views'] ?? 0,
      slug: json['slug'] ?? '',
    );
  }

  // MÉTODO INTELIGENTE PARA PEGAR AS FONTES DE VÍDEO
  List<VideoSource> get videoSources {
    final sources = <VideoSource>[];
    
    // string vazia, e este 'if' vai funcionar corretamente sem quebrar.
    if (linksVideo.isEmpty) {
      return sources;
    }

    final lines = linksVideo.split('\n').where((line) => line.trim().isNotEmpty);

    for (var line in lines) {
      try {
        // Lógica para o "Player Principal" (embedW4)
        if (line.contains('embedW4')) {
          final uri = Uri.parse(line);
          final videoId = uri.pathSegments.last;
          if (videoId.isNotEmpty) {
            sources.add(VideoSource(
              name: 'Player Principal',
              url: '$videoId',
            ));
          }
        }
        // ==========================================================
        // NOVA LÓGICA ADICIONADA AQUI
        // Lógica para o "Player Secundário" (embedW5)
        // ==========================================================
        else if (line.contains('embedW5')) {
          final uri = Uri.parse(line);
          final videoId = uri.pathSegments.last;
          if (videoId.isNotEmpty) {
            sources.add(VideoSource(
              name: 'Player Principal',
              url: '$videoId',
            ));
          }
        }
        // Lógica para o "Player Alternativo" (sec)
        else if (line.contains('sec1')) {
          final uri = Uri.parse(line);
          final videoId = uri.queryParameters['id'];
          if (videoId != null && videoId.isNotEmpty) {
            sources.add(VideoSource(
              name: 'Player Alternativo',
              url: '$videoId',
            ));
          }
        }
      } catch (e) {
        print('Erro ao parsear a linha de vídeo: $line, Erro: $e');
      }
    }
    return sources;
  }
}