import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; 
import '../models/anime_model.dart';
import '../screens/anime_detail_screen.dart';
import 'custom_loading_indicator.dart'; 

class SearchResultTile extends StatelessWidget {
  final Anime anime;

  const SearchResultTile({Key? key, required this.anime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnimeDetailScreen(slug: anime.slug),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem à esquerda
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
             
              child: CachedNetworkImage(
                imageUrl: anime.imagemCapa,
                width: 100,
                height: 150,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                width: 100, height: 150,
                color: Colors.grey.shade800,
                child: const CustomLoadingIndicator(width: 60, height: 60), // <-- LINHA NOVA
                ),
                errorWidget: (context, url, error) => Container(
                  width: 100, height: 150,
                  color: Colors.grey.shade800,
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Coluna de textos à direita
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    anime.nome,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (anime.titleEnglish.isNotEmpty && anime.titleEnglish != anime.nome)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        anime.titleEnglish,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.grey.shade400,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  Text(
                    DateTime.parse(anime.dataPublicacao).year.toString(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey.shade400,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: anime.generos.take(3).map((g) => Chip(
                      label: Text(g.nome),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      backgroundColor: Colors.grey.shade800,
                      labelStyle: const TextStyle(fontSize: 12),
                    )).toList(),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}