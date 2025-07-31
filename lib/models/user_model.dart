// lib/models/user_model.dart

class UserModel {
  final int id;
  final String name;
  final bool isAdmin;
  final String profilePictureUrl;
  final String wallpaperUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.isAdmin,
    required this.profilePictureUrl,
    required this.wallpaperUrl,
  });

  // Factory para criar um usuário a partir do payload decodificado de um JWT
  factory UserModel.fromJwt(Map<String, dynamic> decodedToken) {
    return UserModel(
      id: decodedToken['id'],
      name: decodedToken['nome'],
      isAdmin: decodedToken['is_admin'] == 1 || decodedToken['is_admin'] == true,
      profilePictureUrl: decodedToken['foto_perfil'],
      wallpaperUrl: decodedToken['wallpaper'],
    );
  }
}