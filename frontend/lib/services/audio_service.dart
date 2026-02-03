import 'package:just_audio/just_audio.dart';
import '../models/song.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  Song? _currentSong;
  List<Song> _playlist = [];
  int _currentIndex = 0;

  AudioPlayer get player => _audioPlayer;
  Song? get currentSong => _currentSong;

  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;

  Future<void> playSong(Song song, {List<Song>? playlist}) async {
    _currentSong = song;

    if (playlist != null) {
      _playlist = playlist;
      _currentIndex = playlist.indexWhere((s) => s.id == song.id);
      if (_currentIndex < 0) _currentIndex = 0;
    }

    await _audioPlayer.setUrl(song.songUrl);
    await _audioPlayer.play();
  }

  Future<void> pause() async => _audioPlayer.pause();
  Future<void> resume() async => _audioPlayer.play();
  Future<void> seek(Duration position) async => _audioPlayer.seek(position);

  Future<void> playNext() async {
    if (_currentIndex < _playlist.length - 1) {
      _currentIndex++;
      await playSong(_playlist[_currentIndex], playlist: _playlist);
    }
  }

  Future<void> playPrevious() async {
    if (_currentIndex > 0) {
      _currentIndex--;
      await playSong(_playlist[_currentIndex], playlist: _playlist);
    }
  }

  Future<void> setShuffleMode(bool enabled) async {
    await _audioPlayer.setShuffleModeEnabled(enabled);
  }

  Future<void> setLoopMode(LoopMode mode) async {
    await _audioPlayer.setLoopMode(mode);
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
