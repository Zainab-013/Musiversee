class Song {
  final int id;
  final String name;
  final String movie;
  final String? actor;
  final String? actress;
  final String singer;
  final String composer;
  final String lyricist;
  final String category;
  final String imageUrl;
  final String songUrl;
  bool isLiked;

  Song({
    required this.id,
    required this.name,
    required this.movie,
    this.actor,
    this.actress,
    required this.singer,
    required this.composer,
    required this.lyricist,
    required this.category,
    required this.imageUrl,
    required this.songUrl,
    this.isLiked = false,
  });

  /// ---------- FROM BACKEND JSON ----------
  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as int,
      name: json['songName'] ?? json['song_name'], // safety
      movie: json['movie'] ?? '',
      actor: json['actor'],
      actress: json['actress'],
      singer: json['singer'] ?? '',
      composer: json['composer'] ?? '',
      lyricist: json['lyricist'] ?? '',
      category: json['category'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      songUrl: json['songUrl'] ?? '',
      isLiked: json['isLiked'] ?? false,
    );
  }

  /// ---------- TO BACKEND JSON ----------
  Map<String, dynamic> toJson() {
    return {
      "songName": name,
      "movie": movie,
      "actor": actor,
      "actress": actress,
      "singer": singer,
      "composer": composer,
      "lyricist": lyricist,
      "category": category,
      "imageUrl": imageUrl,
      "songUrl": songUrl,
    };
  }
}
