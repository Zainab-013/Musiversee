import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../providers/music_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/song_card.dart';
import '../models/song.dart';
import 'player_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isPlayingAll = false;
  bool _isShuffling = false;

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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: _isPlayingAll
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.play_arrow, color: AppColors.white),
                  label: Text(_isPlayingAll ? 'Loading...' : 'Play All'),
                  onPressed: _isPlayingAll || _isShuffling
                      ? null
                      : () async {
                          setState(() {
                            _isPlayingAll = true;
                          });
                          try {
                            await musicProvider.playSong(
                              musicProvider.likedSongs.first,
                              playlist: musicProvider.likedSongs,
                            );
                            if (mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PlayerScreen(),
                                ),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isPlayingAll = false;
                              });
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: _isShuffling
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: AppColors.cyan,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.shuffle, color: AppColors.cyan),
                  label: Text(
                    _isShuffling ? 'Shuffling...' : 'Shuffle',
                    style: const TextStyle(color: AppColors.cyan),
                  ),
                  onPressed: _isPlayingAll || _isShuffling
                      ? null
                      : () async {
                          setState(() {
                            _isShuffling = true;
                          });
                          try {
                            final shuffled = List<Song>.from(musicProvider.likedSongs)..shuffle();
                            await musicProvider.playSong(
                              shuffled.first,
                              playlist: shuffled,
                            );
                            if (mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PlayerScreen(),
                                ),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isShuffling = false;
                              });
                            }
                          }
                        },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.cyan),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
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
          ),
        ),
      ],
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