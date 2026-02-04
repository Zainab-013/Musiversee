import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';

class AudioPlayerService {
  // ================= SINGLETON =================
  static final AudioPlayerService _instance =
      AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  final AudioPlayer _player = AudioPlayer();

  List<Song> _playlist = [];
  int _currentIndex = 0;

  // ================= GETTERS =================
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;

  Song? get currentSong =>
      (_playlist.isNotEmpty &&
              _currentIndex >= 0 &&
              _currentIndex < _playlist.length)
          ? _playlist[_currentIndex]
          : null;

  // ================= PLAY SONG =================
  Future<void> playSong(Song song, {List<Song>? playlist}) async {
    if (playlist != null && playlist.isNotEmpty) {
      _playlist = playlist;
      _currentIndex = playlist.indexWhere((s) => s.id == song.id);
      if (_currentIndex < 0) _currentIndex = 0;
    }

    await _player.setUrl(song.songUrl);
    await _player.play();
  }

  // ================= AUTO PLAY NEXT =================
  void initAutoPlayNext(VoidCallback onSongCompleted) {
    _player.playerStateStream.listen((state) async {
      if (state.processingState == ProcessingState.completed) {
        await playNext();
        onSongCompleted();
      }
    });
  }

  // ================= CONTROLS =================
  Future<void> playNext() async {
    if (_playlist.isEmpty) return;

    if (_currentIndex < _playlist.length - 1) {
      _currentIndex++;
    } else {
      // 🔁 loop back to first song
      _currentIndex = 0;
    }

    await _player.setUrl(_playlist[_currentIndex].songUrl);
    await _player.play();
  }

  Future<void> playPrevious() async {
    if (_playlist.isEmpty) return;

    if (_currentIndex > 0) {
      _currentIndex--;
    } else {
      // 🔁 go to last song
      _currentIndex = _playlist.length - 1;
    }

    await _player.setUrl(_playlist[_currentIndex].songUrl);
    await _player.play();
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
