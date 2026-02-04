import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../models/song.dart';
import '../services/api_service.dart';
import '../services/audio_service.dart';

class MusicProvider with ChangeNotifier {
  final AudioPlayerService _audioService = AudioPlayerService();

  List<Song> _allSongs = [];
  List<Song> _likedSongs = [];
  List<Song> _recentlyPlayed = [];

  Song? _currentSong;

  bool _isLoading = false;
  bool _isPlaying = false;

  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // ================= GETTERS =================
  List<Song> get allSongs => _allSongs;
  List<Song> get likedSongs => _likedSongs;
  List<Song> get recentlyPlayed => _recentlyPlayed;

  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;

  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;

  // ================= INIT =================
  MusicProvider() {
    // 🔁 AUTO PLAY NEXT WHEN SONG ENDS
    _audioService.initAutoPlayNext(() {
      _syncCurrentSong();
    });

    _audioService.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });

    _audioService.positionStream.listen((pos) {
      _currentPosition = pos;
      notifyListeners();
    });

    _audioService.durationStream.listen((dur) {
      if (dur != null) {
        _totalDuration = dur;
        notifyListeners();
      }
    });
  }

  // ================= API =================
  Future<void> fetchAllSongs() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allSongs = await ApiService.getAllSongs();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Song>> fetchSongsByCategory(String category) {
    return ApiService.getSongsByCategory(category);
  }

  Future<List<Song>> searchSongs(String query) {
    return ApiService.searchSongs(query);
  }

  Future<void> fetchLikedSongs(int userId) async {
    _likedSongs = await ApiService.getLikedSongs(userId);
    notifyListeners();
  }

  // ================= LIKE HELPERS =================
  bool isSongLiked(int songId) {
    return _likedSongs.any((song) => song.id == songId);
  }

  // ================= PLAYER =================
  Future<void> playSong(Song song, {List<Song>? playlist}) async {
    await _audioService.playSong(
      song,
      playlist: playlist ?? _allSongs,
    );

    _syncCurrentSong();
  }

  Future<void> pauseSong() => _audioService.pause();
  Future<void> resumeSong() => _audioService.resume();

  Future<void> playNext() async {
    await _audioService.playNext();
    _syncCurrentSong();
  }

  Future<void> playPrevious() async {
    await _audioService.playPrevious();
    _syncCurrentSong();
  }

  Future<void> seekTo(Duration pos) => _audioService.seek(pos);

  // ================= LIKE =================
  Future<void> likeSong(int userId, Song song) async {
    if (isSongLiked(song.id)) return;

    await ApiService.likeSong(userId, song.id);
    song.isLiked = true;
    _likedSongs.add(song);
    notifyListeners();
  }

  Future<void> unlikeSong(int userId, Song song) async {
    await ApiService.unlikeSong(userId, song.id);
    song.isLiked = false;
    _likedSongs.removeWhere((s) => s.id == song.id);
    notifyListeners();
  }

  // ================= HELPERS =================
  void _syncCurrentSong() {
    _currentSong = _audioService.currentSong;

    if (_currentSong != null) {
      _recentlyPlayed.removeWhere((s) => s.id == _currentSong!.id);
      _recentlyPlayed.insert(0, _currentSong!);

      if (_recentlyPlayed.length > 20) {
        _recentlyPlayed = _recentlyPlayed.sublist(0, 20);
      }
    }

    notifyListeners();
  }
}
