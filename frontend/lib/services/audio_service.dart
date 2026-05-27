import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../models/song.dart';

class AudioPlayerService {
  // ================= SINGLETON =================
  static final AudioPlayerService _instance =
      AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  
  AudioPlayerService._internal() {
    // 🔁 Automatically keep track of currently playing index when sequence transitions or seeks
    _player.currentIndexStream.listen((index) {
      if (index != null && index >= 0 && index < _playlist.length) {
        _currentIndex = index;
      }
    });
  }

  final AudioPlayer _player = AudioPlayer();

  List<Song> _playlist = [];
  int _currentIndex = 0;

  // ================= GETTERS =================
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<int?> get currentIndexStream => _player.currentIndexStream;

  Song? get currentSong =>
      (_playlist.isNotEmpty &&
              _currentIndex >= 0 &&
              _currentIndex < _playlist.length)
          ? _playlist[_currentIndex]
          : null;

  // ================= SET PLAYLIST SOURCES =================
  Future<void> _setPlaylistSources(List<Song> songs) async {
    final sources = songs.map((song) {
      final mediaItem = MediaItem(
        id: song.id.toString(),
        album: song.movie,
        title: song.name,
        artist: song.singer,
        artUri: song.imageUrl.isNotEmpty ? Uri.parse(song.imageUrl) : null,
      );

      if (kIsWeb) {
        return AudioSource.uri(
          Uri.parse(song.songUrl),
          tag: mediaItem,
        );
      } else {
        return LockCachingAudioSource(
          Uri.parse(song.songUrl),
          tag: mediaItem,
        );
      }
    }).toList();

    await _player.setAudioSource(
      ConcatenatingAudioSource(children: sources),
      initialIndex: _currentIndex,
      initialPosition: Duration.zero,
    );
  }

  // ================= PLAY SONG =================
  Future<void> playSong(Song song, {List<Song>? playlist}) async {
    if (playlist != null && playlist.isNotEmpty) {
      _playlist = playlist;
      _currentIndex = playlist.indexWhere((s) => s.id == song.id);
      if (_currentIndex < 0) _currentIndex = 0;
    } else {
      _playlist = [song];
      _currentIndex = 0;
    }

    try {
      await _setPlaylistSources(_playlist);
      await _player.play();
    } catch (e) {
      debugPrint('Error playing song: $e');
    }
  }

  // ================= AUTO PLAY NEXT =================
  void initAutoPlayNext(VoidCallback onSongCompleted) {
    _player.currentIndexStream.listen((index) {
      if (index != null) {
        onSongCompleted();
      }
    });
  }

  // ================= CONTROLS =================
  Future<void> playNext() async {
    try {
      if (_player.hasNext) {
        await _player.seekToNext();
      } else if (_playlist.isNotEmpty) {
        // Wrap around to start of playlist if no next item natively exists
        _currentIndex = 0;
        await _player.seek(Duration.zero, index: 0);
      }
    } catch (e) {
      debugPrint('Error playing next song: $e');
    }
  }

  Future<void> playPrevious() async {
    try {
      if (_player.hasPrevious) {
        await _player.seekToPrevious();
      } else if (_playlist.isNotEmpty) {
        // Wrap around to end of playlist
        _currentIndex = _playlist.length - 1;
        await _player.seek(Duration.zero, index: _currentIndex);
      }
    } catch (e) {
      debugPrint('Error playing previous song: $e');
    }
  }

  Future<void> pause() => _player.pause();
  Future<void> resume() => _player.play();
  Future<void> seek(Duration pos) => _player.seek(pos);

  // ================= OPTIONAL =================
  Future<void> setShuffle(bool enabled) async {
    await _player.setShuffleModeEnabled(enabled);
  }

  Future<void> setLoopMode(LoopMode mode) async {
    await _player.setLoopMode(mode);
  }

  // ================= DISPOSE =================
  void dispose() {
    _player.dispose();
  }
}
