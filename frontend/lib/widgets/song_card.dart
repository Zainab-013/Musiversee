import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/app_colors.dart';
import '../models/song.dart';

class SongCard extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  final VoidCallback? onLike;
  final bool isLiked;

  const SongCard({
    super.key,
    required this.song,
    required this.onTap,
    this.onLike,
    this.isLiked = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.navyBlue.withOpacity(0.3),
              AppColors.darkViolet.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.cyan.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Song Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryRed.withOpacity(0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: song.imageUrl,
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
            const SizedBox(width: 16),
            // Song Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.singer,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.lightGrey,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (song.movie.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      song.movie,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.cyan.withOpacity(0.7),
                            fontSize: 12,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Like Button
            if (onLike != null)
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? AppColors.primaryRed : AppColors.white,
                ),
                onPressed: onLike,
              ),
          ],
        ),
      ),
    );
  }
}