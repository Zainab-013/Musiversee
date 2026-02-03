import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/app_colors.dart';
import '../providers/music_provider.dart';
import '../screens/player_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, child) {
        final currentSong = musicProvider.currentSong;

        if (currentSong == null) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PlayerScreen(),
              ),
            );
          },
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.navyBlue.withOpacity(0.95),
                  AppColors.darkViolet.withOpacity(0.95),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cyan.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Song Image
                Container(
                  width: 60,
                  height: 60,
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryRed.withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: currentSong.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.darkGrey,
                        child: const Icon(Icons.music_note, color: AppColors.cyan),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.darkGrey,
                        child: const Icon(Icons.music_note, color: AppColors.cyan),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Song Info
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentSong.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currentSong.singer,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.lightGrey,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Like Button
                IconButton(
                  icon: Icon(
                    musicProvider.isSongLiked(currentSong.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: musicProvider.isSongLiked(currentSong.id)
                        ? AppColors.primaryRed
                        : AppColors.white,
                  ),
                  onPressed: () {
                    // TODO: Implement like/unlike with userId
                  },
                ),
                // Play/Pause Button
                IconButton(
                  icon: Icon(
                    musicProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 32,
                  ),
                  color: AppColors.cyan,
                  onPressed: () {
                    if (musicProvider.isPlaying) {
                      musicProvider.pauseSong();
                    } else {
                      musicProvider.resumeSong();
                    }
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}