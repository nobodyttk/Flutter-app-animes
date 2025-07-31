// lib/screens/profile_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/profile_service.dart';
import '../models/user_profile_model.dart';
import '../models/profile_list_item_model.dart';

import '../screens/login_screen.dart';
import '../screens/anime_detail_screen.dart';
import '../widgets/custom_loading_indicator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<UserProfileModel?>? _profileFuture;
  final ProfileService _profileService = ProfileService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (authProvider.isLoggedIn && _profileFuture == null) {
      _profileFuture = _profileService.fetchUserProfile(
        authProvider.user!.name,
        authProvider.token!,
      );
    }
  }
  
  void _refreshProfile() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isLoggedIn) {
      setState(() {
        _profileFuture = _profileService.fetchUserProfile(
          authProvider.user!.name,
          authProvider.token!,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (!authProvider.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Acessar Conta')),
        body: LoginScreen(),
      );
    }
    
    return FutureBuilder<UserProfileModel?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: CustomLoadingIndicator());
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text("Erro")),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Erro ao carregar perfil: ${snapshot.error}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _refreshProfile,
                    child: const Text('Tentar Novamente'),
                  )
                ],
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: Text('Não foi possível carregar o perfil.')));
        }
        
        final userProfile = snapshot.data!;
        
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            body: RefreshIndicator(
              onRefresh: () async => _refreshProfile(),
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      expandedHeight: 250.0,
                      floating: false,
                      pinned: true,
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.logout),
                          tooltip: 'Sair da conta',
                          onPressed: () {
                            Provider.of<AuthProvider>(context, listen: false).logout();
                          },
                        ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(userProfile.nomeUsuario, style: const TextStyle(shadows: [Shadow(blurRadius: 4, color: Colors.black)])),
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: userProfile.wallpaper,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Container(color: Colors.black),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.black.withOpacity(0.6), Colors.transparent, Colors.black.withOpacity(0.6)],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  stops: const [0, 0.5, 1],
                                ),
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 50.0),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundImage: CachedNetworkImageProvider(userProfile.fotoPerfil),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPersistentHeader(
                      delegate: _SliverAppBarDelegate(
                        const TabBar(
                          tabs: [
                            Tab(icon: Icon(Icons.favorite), text: "Favoritos"),
                            Tab(icon: Icon(Icons.check_circle), text: "Completos"),
                          ],
                        ),
                      ),
                      pinned: true,
                    ),
                  ];
                },
                body: TabBarView(
                  children: [
                    _buildAnimeGrid(userProfile.favoritos, context),
                    _buildAnimeGrid(userProfile.completos, context),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimeGrid(List<ProfileListItemModel> animes, BuildContext context) {
    if (animes.isEmpty) {
      return const Center(child: Text("Nenhum anime nesta lista ainda."));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2 / 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: animes.length,
      itemBuilder: (context, index) {
        final anime = animes[index];
        return InkWell(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AnimeDetailScreen(slug: anime.slug)),
            );
            if (result == true) {
              _refreshProfile();
            }
          },
          child: Card(
            elevation: 4,
            clipBehavior: Clip.antiAlias,
            child: CachedNetworkImage(
              imageUrl: anime.imagem,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey.shade800),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}