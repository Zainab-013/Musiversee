import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../providers/music_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/song_card.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        Provider.of<MusicProvider>(context, listen: false)
            .fetchLikedSongs(authProvider.user!.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text(
                      'Library',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ],
                ),
              ),
              // Tab Bar
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.cyan,
                labelColor: AppColors.cyan,
                unselectedLabelColor: AppColors.lightGrey,
                tabs: const [
                  Tab(text: 'Liked Songs'),
                  Tab(text: 'Recently Played'),
                ],
              ),
              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLikedSongs(musicProvider),
                    _buildRecentlyPlayed(musicProvider),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLikedSongs(MusicProvider musicProvider) {
    if (musicProvider.likedSongs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: AppColors.lightGrey),
            SizedBox(height: 16),
            Text(
              'No liked songs yet',
              style: TextStyle(fontSize: 18, color: AppColors.lightGrey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: musicProvider.likedSongs.length,
      itemBuilder: (context, index) {
        final song = musicProvider.likedSongs[index];
        return SongCard(
          song: song,
          onTap: () {
            musicProvider.playSong(song, playlist: musicProvider.likedSongs);
          },
          onLike: () {
            final authProvider =
                Provider.of<AuthProvider>(context, listen: false);
            if (authProvider.user != null) {
              musicProvider.unlikeSong(authProvider.user!.id, song);
            }
          },
          isLiked: true,
        );
      },
    );
  }

  Widget _buildRecentlyPlayed(MusicProvider musicProvider) {
    if (musicProvider.recentlyPlayed.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: AppColors.lightGrey),
            SizedBox(height: 16),
            Text(
              'No recently played songs',
              style: TextStyle(fontSize: 18, color: AppColors.lightGrey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: musicProvider.recentlyPlayed.length,
      itemBuilder: (context, index) {
        final song = musicProvider.recentlyPlayed[index];
        return SongCard(
          song: song,
          onTap: () {
            musicProvider.playSong(song,
                playlist: musicProvider.recentlyPlayed);
          },
          onLike: () {
            final authProvider =
                Provider.of<AuthProvider>(context, listen: false);
            if (authProvider.user != null) {
              if (musicProvider.isSongLiked(song.id)) {
                musicProvider.unlikeSong(authProvider.user!.id, song);
              } else {
                musicProvider.likeSong(authProvider.user!.id, song);
              }
            }
          },
          isLiked: musicProvider.isSongLiked(song.id),
        );
      },
    );
  }
}