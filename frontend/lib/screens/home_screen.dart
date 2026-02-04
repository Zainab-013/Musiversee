import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../config/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/music_provider.dart';
import '../models/song.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MusicProvider>().fetchAllSongs();
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final music = context.watch<MusicProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SafeArea(
          child: music.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.cyan))
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      floating: true,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_getGreeting(),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          Text(auth.user?.name ?? 'Music Lover',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: AppColors.cyan)),
                        ],
                      ),
                    ),

                    // Search bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SearchScreen()),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              color: AppColors.darkGrey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.search, color: AppColors.lightGrey),
                                SizedBox(width: 12),
                                Text('Search songs, artists, movies',
                                    style: TextStyle(color: AppColors.lightGrey)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Featured
                    if (music.allSongs.isNotEmpty)
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 200,
                          child: PageView.builder(
                            controller: PageController(viewportFraction: 0.9),
                            itemCount: music.allSongs.take(5).length,
                            itemBuilder: (context, index) {
                              final song = music.allSongs[index];
                              return _FeaturedSongCard(
                                song: song,
                                onTap: () => music.playSong(song, playlist: music.allSongs),
                              ).animate().fadeIn(duration: 300.ms);
                            },
                          ),
                        ),
                      ),

                    // Recommended
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final song = music.allSongs[index];
                          return _RecommendedSongTile(
                            song: song,
                            isLiked: music.isSongLiked(song.id),
                            onTap: () => music.playSong(song, playlist: music.allSongs),
                            onLike: () {
                              if (auth.user == null) return;
                              music.isSongLiked(song.id)
                                  ? music.unlikeSong(auth.user!.id!, song)
                                  : music.likeSong(auth.user!.id!,song);
                            },
                          );
                        },
                        childCount: music.allSongs.length,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/* ---------- Widgets ---------- */

class _FeaturedSongCard extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  const _FeaturedSongCard({required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CachedNetworkImage(imageUrl: song.imageUrl, fit: BoxFit.cover),
      ),
    );
  }
}

class _RecommendedSongTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final bool isLiked;

  const _RecommendedSongTile({
    required this.song,
    required this.onTap,
    required this.onLike,
    required this.isLiked,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(imageUrl: song.imageUrl, width: 56, height: 56),
      ),
      title: Text(song.name),
      subtitle: Text(song.singer),
      trailing: IconButton(
        icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? AppColors.primaryRed : AppColors.white),
        onPressed: onLike,
      ),
    );
  }
}
