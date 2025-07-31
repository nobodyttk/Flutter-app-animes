// lib/screens/loading_screen.dart

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../providers/genre_provider.dart';
import 'animes_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _loadDataAndNavigate();
  }

  Future<void> _loadDataAndNavigate() async {
    // 1. Pega uma referência ao GenreProvider. Como ele é "lazy" por padrão,
    // a busca na API ainda não começou.
    final genreProvider = Provider.of<GenreProvider>(context, listen: false);

    // 2. Inicia o carregamento dos gêneros e espera ele terminar.
    // Usamos Future.wait para carregar múltiplas coisas em paralelo no futuro, se precisar.
    await Future.wait([
      genreProvider.fetchGenres(), // O fetchGenres retorna um Future<void>
      // Pode adicionar outros Futures aqui, ex:
      // Future.delayed(const Duration(seconds: 2)), // Garante que a animação rode por 2s
    ]);

    // 3. Após tudo carregar, navega para a tela principal.
    // Usamos `pushReplacement` para que o usuário não possa voltar para a tela de loading.
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const AnimesScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Mostra a animação Lottie a partir do arquivo que adicionamos
        child: Lottie.asset(
          'assets/animations/Loading.json',
          width: 200,
          height: 200,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}