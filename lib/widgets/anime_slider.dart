// lib/widgets/anime_slider.dart

import 'package:flutter/material.dart' hide CarouselController;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../models/anime_model.dart';
import '../services/anime_service.dart';
import '../screens/anime_detail_screen.dart';
import 'custom_loading_indicator.dart';

class AnimeSlider extends StatefulWidget {
  const AnimeSlider({Key? key}) : super(key: key);

  @override
  State<AnimeSlider> createState() => _AnimeSliderState();
}

class _AnimeSliderState extends State<AnimeSlider> {
  late Future<List<Anime>> _sliderAnimesFuture;

  @override
  void initState() {
    super.initState();
    _sliderAnimesFuture = AnimeService.getSliderAnimes();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Anime>>(
      future: _sliderAnimesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 450,
            child: CustomLoadingIndicator(),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final animes = snapshot.data!;

        return CarouselSlider.builder(
          itemCount: animes.length,
          itemBuilder: (context, index, realIndex) {
            final anime = animes[index];
            return _buildSliderItem(context, anime);
          },
          options: CarouselOptions(
            height: 450.0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 6),
            viewportFraction: 1.0,
            enlargeCenterPage: false,
          ),
        );
      },
    );
  }

  Widget _buildSliderItem(BuildContext context, Anime anime) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AnimeDetailScreen(slug: anime.slug)),
        );
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: anime.imagemSlide,
              fit: BoxFit.cover,
              placeholder: (context, url) => const CustomLoadingIndicator(),
              errorWidget: (context, url, error) => Container(color: Colors.black),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.9)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.4, 0.6, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 30.0,
            left: 20.0,
            right: 20.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  anime.nome,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  anime.generos.map((g) => g.nome).join(' • '),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    ElevatedButton.icon(
                      
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AnimeDetailScreen(slug: anime.slug),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_arrow, color: Colors.black),
                      label: const Text('Play', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(width: 12),
                /*    OutlinedButton.icon(
                      onPressed: () { /* TODO: Implementar lógica de 'Minha Lista' */ },
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('Minha Lista', style: TextStyle(color: Colors.white)),
                       style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ), */
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}