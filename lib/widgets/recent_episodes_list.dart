// lib/widgets/recent_episodes_list.dart

import 'package:flutter/material.dart';
import '../models/episodio_model.dart';
import '../services/anime_service.dart';
import 'custom_loading_indicator.dart';
import 'episode_home_card.dart';

class RecentEpisodesList extends StatefulWidget {
  const RecentEpisodesList({Key? key}) : super(key: key);

  @override
  State<RecentEpisodesList> createState() => _RecentEpisodesListState();
}

class _RecentEpisodesListState extends State<RecentEpisodesList> {
  late Future<List<Episodio>> _futureEpisodios;

  @override
  void initState() {
    super.initState();
    _futureEpisodios = AnimeService.getEpisodiosRecentes();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Episodio>>(
      future: _futureEpisodios,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Usamos uma altura fixa para o loading não "pular" a tela
          return const SizedBox(
            height: 220,
            child: CustomLoadingIndicator(),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          // Se der erro, não mostramos nada para não quebrar o layout
          return const SizedBox.shrink();
        }

        final episodios = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Título da Seção (usando o mesmo estilo que definimos antes)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Episódios Recentes',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Carrossel Horizontal de Episódios
            SizedBox(
              height: 150, // Altura suficiente para o EpisodeCard
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: episodios.length,
                itemBuilder: (context, index) {
               final episodio = episodios[index];
                 return EpisodeHomeCard(episodio: episodio); // <-- LINHA NOVA
                },
              ),
            ),
          ],
        );
      },
    );
  }
}