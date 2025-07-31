// Classe para o objeto aninhado 'generos'
class Genero {
  final int id;
  final String nome;

  Genero({required this.id, required this.nome});

  factory Genero.fromJson(Map<String, dynamic> json) {
    return Genero(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? 'Desconhecido',
    );
  }
}

// Classe para o objeto aninhado 'temporada'
class Temporada {
  final int id;
  final int numero;
  final String titulo;
  final String dataLancamento;

  Temporada({
    required this.id,
    required this.numero,
    required this.titulo,
    required this.dataLancamento,
  });

  factory Temporada.fromJson(Map<String, dynamic> json) {
    return Temporada(
      id: json['id'] ?? 0,
      numero: json['numero'] ?? 1,
      titulo: json['titulo'] ?? 'Temporada desconhecida',
      dataLancamento: json['data_lancamento'] ?? '',
    );
  }
}

// Classe principal do Anime, agora com todos os campos da API
class Anime {
  final int id;
  final String nome;
  final String titleEnglish; 
  final String imagemCapa;
  final String imagemSlide;
  final String dataPublicacao;
  final String sinopse;
  final String slug;
  final String status;
  final String duration;
  final int views;
  final List<Genero> generos;
  final Temporada? temporada; // Pode ser nulo

  Anime({
    required this.id,
    required this.nome,
    required this.titleEnglish,
    required this.imagemCapa,
    required this.imagemSlide,
    required this.dataPublicacao,
    required this.sinopse,
    required this.slug,
    required this.status,
    required this.duration,
    required this.views,
    required this.generos,
    this.temporada,
  });

  // Factory atualizado para converter o JSON completo em um objeto Anime
  factory Anime.fromJson(Map<String, dynamic> json) {
    // Converte a lista de JSON de gêneros em uma lista de objetos Genero
    var generosList = <Genero>[];
    if (json['generos'] != null && json['generos'] is List) {
      generosList = (json['generos'] as List)
          .map((g) => Genero.fromJson(g))
          .toList();
    }

    // Cria o objeto Temporada se ele existir no JSON
    final temporadaData = json['temporada'] != null
        ? Temporada.fromJson(json['temporada'])
        : null;

    return Anime(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? 'Nome não encontrado',
       titleEnglish: json['title_english'] ?? '',
      imagemCapa: json['imagem_capa'] ?? '',
      imagemSlide: json['imagem_slide'] ?? '',
      dataPublicacao: json['data_publicacao'] ?? '',
      sinopse: json['sinopse'] ?? 'Sinopse não disponível.',
      slug: json['slug'] ?? '',
      status: json['status'] ?? 'Não informado',
      duration: json['duration'] ?? 'Não informado',
      views: json['views'] ?? 0,
      generos: generosList,
      temporada: temporadaData,
    );
  }
}