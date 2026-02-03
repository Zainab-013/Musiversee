import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';

import '../config/app_colors.dart';
import '../providers/music_provider.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, _) {
        final song = musicProvider.currentSong;

        if (song == null) {
          return const Scaffold(
            body: Center(child: Text('No song playing')),
          );
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.keyboard_arrow_down, size: 32),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: CachedNetworkImageProvider(song.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.5),
                      Colors.black.withOpacity(0.9),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Spacer(),

                        // Album Art
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CachedNetworkImage(
                            imageUrl: song.imageUrl,
                            width: MediaQuery.of(context).size.width * 0.75,
                            height: MediaQuery.of(context).size.width * 0.75,
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Song Info
                        Text(
                          song.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          song.singer,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: AppColors.cyan),
                        ),

                        const Spacer(),

                        // Progress Slider
                        Slider(
                          value: musicProvider.currentPosition.inSeconds.toDouble(),
                          max: musicProvider.totalDuration.inSeconds > 0
                              ? musicProvider.totalDuration.inSeconds.toDouble()
                              : 1,
                          onChanged: (value) {
                            musicProvider.seekTo(
                              Duration(seconds: value.toInt()),
                            );
                          },
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatDuration(musicProvider.currentPosition)),
                            Text(_formatDuration(musicProvider.totalDuration)),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.skip_previous),
                              iconSize: 40,
                              onPressed: musicProvider.playPrevious,
                            ),
                            IconButton(
                              icon: Icon(
                                musicProvider.isPlaying
                                    ? Icons.pause_circle
                                    : Icons.play_circle,
                              ),
                              iconSize: 64,
                              onPressed: () {
                                musicProvider.isPlaying
                                    ? musicProvider.pauseSong()
                                    : musicProvider.resumeSong();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.skip_next),
                              iconSize: 40,
                              onPressed: musicProvider.playNext,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Like Button
                        IconButton(
                          icon: Icon(
                            musicProvider.isSongLiked(song.id)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: AppColors.primaryRed,
                          ),
                          iconSize: 32,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
