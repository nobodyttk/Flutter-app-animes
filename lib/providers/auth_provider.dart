// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  bool _isInitialized = false;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoggedIn => _token != null;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  AuthProvider() {
    tryAutoLogin();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final token = await _authService.login(email, password);
      _token = token;
      
      // Decodifica o token para obter os dados do usuário
      Map<String, dynamic> payload = Jwt.parseJwt(token);
      _user = UserModel.fromJwt(payload);

      // Salva o token para logins futuros
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', token);
      
    } catch (e) {
      rethrow; // Re-lança o erro para a UI tratar
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('authToken')) {
      _token = prefs.getString('authToken');
      if (_token != null) {
        Map<String, dynamic> payload = Jwt.parseJwt(_token!);
        _user = UserModel.fromJwt(payload);
      }
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    
    notifyListeners();
  }
}