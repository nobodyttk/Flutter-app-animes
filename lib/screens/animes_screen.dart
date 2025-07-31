// lib/screens/animes_screen.dart

import 'package:flutter/material.dart';
import '../widgets/modern_header.dart';
import '../widgets/anime_card.dart';
import '../models/anime_model.dart';
import '../services/anime_service.dart';
import 'anime_detail_screen.dart';
import '../widgets/custom_loading_indicator.dart'; 
import '../widgets/anime_slider.dart'; 
import '../widgets/recent_episodes_list.dart'; 

class AnimesScreen extends StatelessWidget {
  const AnimesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Estilo de texto reutilizável para os títulos das seções
    final sectionTitleStyle = TextStyle(
      fontFamily: 'Poppins',
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).textTheme.bodyLarge?.color,
    );

    return Scaffold(
      appBar: ModernHeader(
        onSearchPressed: () => print('Pesquisa pressionada'),
        onArchivePressed: () => print('Botão de Arquivo/Salvos pressionado'),
        onProfilePressed: () => print('Botão de Perfil pressionado'),
      ),
      
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seção 1: Slider Principal
            const AnimeSlider(),
            const SizedBox(height: 24),

            // Seção 2: Animes Recentes (Lista Horizontal)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Animes Recentes', style: sectionTitleStyle),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 230,
              child: FutureBuilder<List<Anime>>(
                future: AnimeService.getAnimesRecentes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CustomLoadingIndicator(); 
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Erro ao carregar animes: ${snapshot.error}'));
                  }
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final animes = snapshot.data!;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: animes.length,
                      itemBuilder: (context, index) {
                        final anime = animes[index];
                        return AnimeCard(
                          anime: anime,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AnimeDetailScreen(slug: anime.slug),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                  return const Center(child: Text('Nenhum anime recente encontrado'));
                },
              ),
            ),
            const SizedBox(height: 40),

            // Seção 3: Episódios Recentes (Componente próprio)
            const RecentEpisodesList(),
            const SizedBox(height: 0),
            
            // ==========================================================
           
            // ==========================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Os Mais Acessados', style: sectionTitleStyle),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 230, // Mesma altura da lista de "Recentes" para consistência
              child: FutureBuilder<List<Anime>>(
                future: AnimeService.getMaisVisualizadosAnimes(), // Chamando o novo método
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CustomLoadingIndicator(); 
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Erro: ${snapshot.error}'));
                  }
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final animes = snapshot.data!;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: animes.length,
                      itemBuilder: (context, index) {
                        final anime = animes[index];
                        // Reutilizando o mesmo AnimeCard e a mesma lógica de navegação
                        return AnimeCard(
                          anime: anime,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AnimeDetailScreen(slug: anime.slug),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                  return const Center(child: Text('Nenhum anime encontrado'));
                },
              ),
            ),
            // Espaçamento final para a rolagem ficar mais suave
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}