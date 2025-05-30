import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';
import '../services/song_service.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:path_provider/path_provider.dart';

class SongViewmodel extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;

  List<Song> _playlist = [];
  int _currentSongIndex = -1;
  bool _isLoading = false;
  String? _error;

  SongViewmodel() {
    // Inicializamos la escucha de streams del audio player
    listenToDuration();

    // Escucha eventos del servicio de fondo para progreso de descarga
    FlutterBackgroundService().on('downloadProgress').listen((event) {
      final filename = event?['filename'] as String?;
      final progress = event?['progress'] as double?;

      if (filename != null && progress != null) {
        Song? song;
        for (var s in _playlist) {
          if (_fileNameForSong(s) == filename) {
            song = s;
            break;
          }
        }
        if (song != null) {
          song.downloadProgress = progress;
          notifyListeners();
        }
      }
    });

    // Escucha eventos cuando se completa una descarga
    FlutterBackgroundService().on('downloadComplete').listen((event) {
      final filename = event?['filename'] as String?;
      if (filename != null) {
        Song? song;
        for (var s in _playlist) {
          if (_fileNameForSong(s) == filename) {
            song = s;
            break;
          }
        }
        if (song != null) {
          song.isDownloaded = true;
          song.downloadProgress = 1.0;
          notifyListeners();
        }
      }
    });
  }

  Future<void> loadPlaylist() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _playlist = await SongService.fetchPlaylist();
      final dir = await getApplicationDocumentsDirectory();

      for (var song in _playlist) {
        final file = File('${dir.path}/${_fileNameForSong(song)}');
        song.isDownloaded = await file.exists();
        if (song.isDownloaded) song.downloadProgress = 1.0;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> play(int index) async {
    if (index < 0 || index >= _playlist.length) return;

    _currentSongIndex = index;
    final song = _playlist[index];
    String path;

    if (song.isDownloaded) {
      final dir = await getApplicationDocumentsDirectory();
      path = '${dir.path}/${_fileNameForSong(song)}';
    } else {
      path = song.url;
    }

    try {
      await _audioPlayer.setUrl(path);
      await _audioPlayer.load();
      await _audioPlayer.play();
    } catch (e) {
      print("Error al reproducir: $e");
    }


    notifyListeners();
  }

  void listenToDuration() {
    _audioPlayer.durationStream.listen((newDuration) {
      if (newDuration != null) {
        _totalDuration = newDuration;
        notifyListeners();
      }
    });

    _audioPlayer.positionStream.listen((newPosition) {
      _currentDuration = newPosition;
      notifyListeners();
    });

    _audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        playNext();
      }
    });
  }

  void pause() {
    _audioPlayer.pause();
    notifyListeners();
  }

  void resume() {
    _audioPlayer.play();
    notifyListeners();
  }

  void togglePlayPause() {
    if (_audioPlayer.playing) {
      pause();
    } else {
      resume();
    }
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
    notifyListeners();
  }

  Future<void> playNext() async {
    if (_currentSongIndex < _playlist.length - 1) {
      await play(_currentSongIndex + 1);
    } else {
      _currentSongIndex = 0;
      await play(_currentSongIndex);
    }
  }

  Future<void> playPrevious() async {
    final currentPosition = _audioPlayer.position;

    if (currentPosition > Duration(seconds: 2)) {
      await seek(Duration.zero);
    } else {
      if (_currentSongIndex > 0) {
        await play(_currentSongIndex - 1);
      } else {
        await play(_playlist.length - 1);
      }
    }
  }

  void downloadSong(Song song) {
    final filename = _fileNameForSong(song);
    FlutterBackgroundService().invoke('download', {
      'url': song.url,
      'filename': filename,
    });
  }

  String _fileNameForSong(Song song) {
    return '${song.title.toLowerCase().replaceAll(' ', '_')}.mp3';
  }

  List<Song> get playlist => _playlist;
  AudioPlayer get audioPlayer => _audioPlayer;
  Song? get currentMusic =>
      (_currentSongIndex >= 0 && _currentSongIndex < _playlist.length) ? _playlist[_currentSongIndex] : null;

  int get currentSongIndex => _currentSongIndex;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Duration get currentDuration => _currentDuration;
  Duration get totalDuration => _totalDuration;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
