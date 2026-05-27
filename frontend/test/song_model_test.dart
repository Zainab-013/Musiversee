import 'package:flutter_test/flutter_test.dart';
import 'package:musiverse/models/song.dart';

void main() {
  group('Song Model Unit Tests', () {
    test('fromJson should parse backend JSON correctly', () {
      final json = {
        'id': 1,
        'songName': 'Dil Se Re',
        'movie': 'Dil Se',
        'actor': 'Shah Rukh Khan',
        'actress': 'Manisha Koirala',
        'singer': 'A.R. Rahman',
        'composer': 'A.R. Rahman',
        'lyricist': 'Gulzar',
        'category': 'Romantic',
        'imageUrl': 'https://res.cloudinary.com/covers/dil_se.jpg',
        'songUrl': 'https://res.cloudinary.com/audio/dil_se.mp3',
        'isLiked': true,
      };

      final song = Song.fromJson(json);

      expect(song.id, 1);
      expect(song.name, 'Dil Se Re');
      expect(song.movie, 'Dil Se');
      expect(song.actor, 'Shah Rukh Khan');
      expect(song.actress, 'Manisha Koirala');
      expect(song.singer, 'A.R. Rahman');
      expect(song.composer, 'A.R. Rahman');
      expect(song.lyricist, 'Gulzar');
      expect(song.category, 'Romantic');
      expect(song.imageUrl, 'https://res.cloudinary.com/covers/dil_se.jpg');
      expect(song.songUrl, 'https://res.cloudinary.com/audio/dil_se.mp3');
      expect(song.isLiked, true);
    });

    test('toJson should construct correct JSON map', () {
      final song = Song(
        id: 2,
        name: 'Chaiyya Chaiyya',
        movie: 'Dil Se',
        actor: 'Shah Rukh Khan',
        actress: 'Malaika Arora',
        singer: 'Sukhwinder Singh',
        composer: 'A.R. Rahman',
        lyricist: 'Gulzar',
        category: 'Dance',
        imageUrl: 'https://res.cloudinary.com/covers/chaiyya.jpg',
        songUrl: 'https://res.cloudinary.com/audio/chaiyya.mp3',
        isLiked: false,
      );

      final json = song.toJson();

      expect(json['songName'], 'Chaiyya Chaiyya');
      expect(json['movie'], 'Dil Se');
      expect(json['actor'], 'Shah Rukh Khan');
      expect(json['actress'], 'Malaika Arora');
      expect(json['singer'], 'Sukhwinder Singh');
      expect(json['composer'], 'A.R. Rahman');
      expect(json['lyricist'], 'Gulzar');
      expect(json['category'], 'Dance');
      expect(json['imageUrl'], 'https://res.cloudinary.com/covers/chaiyya.jpg');
      expect(json['songUrl'], 'https://res.cloudinary.com/audio/chaiyya.mp3');
    });
  });
}
