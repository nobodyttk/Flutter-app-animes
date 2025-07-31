// lib/models/profile_list_item_model.dart

class ProfileListItemModel {
  final int animeId;
  final String nome;
  final String imagem;
  final String slug;

  ProfileListItemModel({
    required this.animeId,
    required this.nome,
    required this.imagem,
    required this.slug,
  });

  factory ProfileListItemModel.fromJson(Map<String, dynamic> json) {
    return ProfileListItemModel(
      animeId: json['anime_id'],
      nome: json['nome'],
      imagem: json['imagem'],
      slug: json['slug'],
    );
  }
}