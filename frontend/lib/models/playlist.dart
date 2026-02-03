import 'song.dart';

class Playlist {
  final String id;
  final String name;
  final String imageUrl;
  final List<Song> songs;

  Playlist({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.songs,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      songs: (json['songs'] as List<dynamic>?)
              ?.map((song) => Song.fromJson(song as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'songs': songs.map((song) => song.toJson()).toList(),
    };
  }

  int get songCount => songs.length;
}