import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';
import '../services/song_service.dart';

class SongViewmodel with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Song> _playlist = [];
  int _currentIndex = -1;
  bool _isLoading = false;
  String? _error;

  List<Song> get playlist => _playlist;
  AudioPlayer get audioPlayer => _audioPlayer;
  Song? get currentMusic =>
      (_currentIndex >= 0 && _currentIndex < _playlist.length) ? _playlist[_currentIndex] : null;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPlaylist() async {
    if (_playlist.isNotEmpty || _isLoading) return; // evita recarga si ya cargó

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _playlist = await SongService.fetchPlaylist();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> playMusic(int index) async {
    if (index >= 0 && index < _playlist.length) {
      _currentIndex = index;
      await _audioPlayer.setUrl(_playlist[index].url);
      await _audioPlayer.play();
      notifyListeners();
    }
  }

  void pauseMusic() {
    _audioPlayer.pause();
    notifyListeners();
  }
}
