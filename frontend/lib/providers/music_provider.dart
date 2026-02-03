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
  bool _isShuffleEnabled = false;

  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  LoopMode _loopMode = LoopMode.off;

  // ================= GETTERS =================
  List<Song> get allSongs => _allSongs;
  List<Song> get likedSongs => _likedSongs;
  List<Song> get recentlyPlayed => _recentlyPlayed;

  Song? get currentSong => _currentSong;

  bool get isLoading => _isLoading;
  bool get isPlaying => _isPlaying;
  bool get isShuffleEnabled => _isShuffleEnabled;

  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;

  LoopMode get loopMode => _loopMode;

  // ================= INIT =================
  MusicProvider() {
    _initPlayerListeners();
  }

  void _initPlayerListeners() {
    _audioService.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });

    _audioService.positionStream.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });

    _audioService.durationStream.listen((duration) {
      if (duration != null) {
        _totalDuration = duration;
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
    } catch (e) {
      debugPrint('Error fetching all songs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Song>> fetchSongsByCategory(String category) async {
    try {
      return await ApiService.getSongsByCategory(category);
    } catch (e) {
      debugPrint('Error fetching category songs: $e');
      return [];
    }
  }

  Future<List<Song>> searchSongs(String query) async {
    try {
      return await ApiService.searchSongs(query);
    } catch (e) {
      debugPrint('Error searching songs: $e');
      return [];
    }
  }

  Future<void> fetchLikedSongs(String userId) async {
    try {
      _likedSongs = await ApiService.getLikedSongs(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching liked songs: $e');
    }
  }

  // ================= PLAYER =================
  Future<void> playSong(Song song, {List<Song>? playlist}) async {
    try {
      _currentSong = song;

      await _audioService.playSong(
        song,
        playlist: playlist ?? _allSongs,
      );

      _recentlyPlayed.removeWhere((s) => s.id == song.id);
      _recentlyPlayed.insert(0, song);

      if (_recentlyPlayed.length > 20) {
        _recentlyPlayed = _recentlyPlayed.sublist(0, 20);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error playing song: $e');
    }
  }

  Future<void> pauseSong() async => _audioService.pause();
  Future<void> resumeSong() async => _audioService.resume();

  Future<void> playNext() async {
    await _audioService.playNext();
    _currentSong = _audioService.currentSong;
    notifyListeners();
  }

  Future<void> playPrevious() async {
    await _audioService.playPrevious();
    _currentSong = _audioService.currentSong;
    notifyListeners();
  }

  Future<void> seekTo(Duration position) async {
    await _audioService.seek(position);
  }

  Future<void> toggleShuffle() async {
    _isShuffleEnabled = !_isShuffleEnabled;
    await _audioService.setShuffleMode(_isShuffleEnabled);
    notifyListeners();
  }

  Future<void> toggleLoopMode() async {
    switch (_loopMode) {
      case LoopMode.off:
        _loopMode = LoopMode.one;
        break;
      case LoopMode.one:
        _loopMode = LoopMode.all;
        break;
      case LoopMode.all:
        _loopMode = LoopMode.off;
        break;
    }
    await _audioService.setLoopMode(_loopMode);
    notifyListeners();
  }

  // ================= LIKE / UNLIKE =================
  Future<void> likeSong(String userId, Song song) async {
    try {
      await ApiService.likeSong(userId, song.id);
      song.isLiked = true;

      if (!_likedSongs.any((s) => s.id == song.id)) {
        _likedSongs.add(song);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error liking song: $e');
    }
  }

  Future<void> unlikeSong(String userId, Song song) async {
    try {
      await ApiService.unlikeSong(userId, song.id);
      song.isLiked = false;

      _likedSongs.removeWhere((s) => s.id == song.id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error unliking song: $e');
    }
  }

  bool isSongLiked(int songId) {
    return _likedSongs.any((song) => song.id == songId);
  }

  // ================= CLEANUP =================
  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
