// lib/models/user_profile_model.dart

import 'profile_list_item_model.dart';

class UserProfileModel {
  final int usuarioId;
  final String nomeUsuario;
  final String fotoPerfil;
  final String wallpaper;
  final List<ProfileListItemModel> favoritos;
  final List<ProfileListItemModel> completos;

  UserProfileModel({
    required this.usuarioId,
    required this.nomeUsuario,
    required this.fotoPerfil,
    required this.wallpaper,
    required this.favoritos,
    required this.completos,
  });

  // 👇 NOVA LÓGICA NO FACTORY CONSTRUCTOR
  factory UserProfileModel.fromJson(Map<String, dynamic> favData, Map<String, dynamic> compData) {
    
    // Mapeia as listas de animes
    final List<ProfileListItemModel> favoritos = (favData['favoritos'] as List)
        .map((item) => ProfileListItemModel.fromJson(item))
        .toList();
    
    final List<ProfileListItemModel> completos = (compData['completos'] as List)
        .map((item) => ProfileListItemModel.fromJson(item))
        .toList();

    // Constrói o modelo final combinando as duas respostas e adicionando os fallbacks
    return UserProfileModel(
      usuarioId: favData['usuario_id'],
      nomeUsuario: favData['nome_usuario'],
      
      // AQUI ESTÁ A GARANTIA: Se a API retornar null, usamos a URL padrão
      fotoPerfil: favData['foto_perfil'] ?? 'https://i.ibb.co/',
      wallpaper: favData['wallpaper'] ?? 'https://i.ibb.co/',
      
      favoritos: favoritos,
      completos: completos,
    );
  }
}