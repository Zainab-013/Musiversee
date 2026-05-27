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
  List<Song> _hiddenSongs = [];

  Song? _currentSong;

  bool _isLoading = false;
  bool _isPlaying = false;

  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // ================= GETTERS =================
  List<Song> get allSongs => _allSongs;
  List<Song> get likedSongs => _likedSongs;
  List<Song> get recentlyPlayed => _recentlyPlayed;
  List<Song> get hiddenSongs => _hiddenSongs;

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
    // Skip for guest user (id=0)
    if (userId == 0) return;
    try {
      _likedSongs = await ApiService.getLikedSongs();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching liked songs: $e');
    }
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

    try {
      if (userId != 0) {
        await ApiService.likeSong(song.id);
      }
      song.isLiked = true;
      _likedSongs.add(song);
      notifyListeners();
    } catch (e) {
      debugPrint('Error liking song: $e');
    }
  }

  Future<void> unlikeSong(int userId, Song song) async {
    try {
      if (userId != 0) {
        await ApiService.unlikeSong(song.id);
      }
      song.isLiked = false;
      _likedSongs.removeWhere((s) => s.id == song.id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error unliking song: $e');
    }
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

  Future<void> deleteSong(int songId) async {
    _allSongs.removeWhere((s) => s.id == songId);
    _likedSongs.removeWhere((s) => s.id == songId);
    _recentlyPlayed.removeWhere((s) => s.id == songId);
    notifyListeners();

    try {
      await ApiService.deleteSong(songId);
    } catch (e) {
      debugPrint('Error deleting song on backend: $e');
    }
  }

  Future<void> fetchHiddenSongs() async {
    try {
      _hiddenSongs = await ApiService.getHiddenSongs();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching hidden songs: $e');
    }
  }

  Future<void> unhideSong(Song song) async {
    try {
      await ApiService.unhideSong(song.id);
      _hiddenSongs.removeWhere((s) => s.id == song.id);
      notifyListeners();
      await fetchAllSongs();
    } catch (e) {
      debugPrint('Error unhiding song: $e');
    }
  }
}
