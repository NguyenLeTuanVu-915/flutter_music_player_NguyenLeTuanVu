import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';
import '../models/playback_state_model.dart';
import '../services/audio_player_service.dart';
import '../services/storage_service.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayerService _audioService;
  final StorageService _storageService;
  final Random _random = Random();

  List<SongModel> _queue = [];
  final List<int> _shuffleHistory = [];
  int _currentIndex = 0;
  bool _isShuffleEnabled = false;
  LoopMode _loopMode = LoopMode.off;
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _sleepTimer;
  Duration? _sleepTimerRemaining;
  double _volume = 1.0;
  double _speed = 1.0;

  AudioProvider(this._audioService, this._storageService) {
    _init();
  }

  List<SongModel> get queue => _queue;
  int get currentIndex => _currentIndex;
  SongModel? get currentSong => _queue.isEmpty ? null : _queue[_currentIndex];
  bool get isShuffleEnabled => _isShuffleEnabled;
  LoopMode get loopMode => _loopMode;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Duration? get sleepTimerRemaining => _sleepTimerRemaining;
  double get volume => _volume;
  double get speed => _speed;
  bool get isPlaying => _audioService.isPlaying;
  bool get hasQueue => _queue.isNotEmpty;

  Stream<Duration> get positionStream => _audioService.positionStream;
  Stream<Duration?> get durationStream => _audioService.durationStream;
  Stream<bool> get playingStream => _audioService.playingStream;
  Stream<double> get volumeStream => _audioService.volumeStream;
  Stream<PlaybackState> get playbackStateStream =>
      _audioService.playbackStateStream;

  Future<void> _init() async {
    _isShuffleEnabled = await _storageService.getShuffleState();
    final repeatIndex = await _storageService.getRepeatMode();
    _loopMode =
    LoopMode.values[repeatIndex.clamp(0, LoopMode.values.length - 1)];
    await _audioService.setLoopMode(_loopMode);

    _volume = await _storageService.getVolume();
    await _audioService.setVolume(_volume);

    _audioService.playerStateStream.listen((state) async {
      if (state.processingState == ProcessingState.completed) {
        await _onSongCompleted();
      }
    });

    notifyListeners();
  }

  Future<void> _onSongCompleted() async {
    if (_loopMode == LoopMode.one) {
      await _playSongAtIndex(_currentIndex);
      return;
    }
    if (_loopMode == LoopMode.off &&
        _currentIndex >= _queue.length - 1 &&
        !_isShuffleEnabled) {
      return;
    }
    await next();
  }

  Future<void> setQueue(List<SongModel> songs, int startIndex) async {
    _queue = List<SongModel>.from(songs);
    _shuffleHistory.clear();
    _currentIndex = startIndex.clamp(0, songs.length - 1);
    await _playSongAtIndex(_currentIndex);
    notifyListeners();
  }

  Future<void> setPlaylist(List<SongModel> songs, int startIndex) =>
      setQueue(songs, startIndex);

  Future<void> _playSongAtIndex(int index) async {
    if (_queue.isEmpty || index < 0 || index >= _queue.length) return;

    _currentIndex = index;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final song = _queue[index];
    try {
      if (song.isAsset) {
        await _audioService.loadAssetAudio(song.filePath);
      } else {
        await _audioService.loadAudio(song.filePath);
      }
      await _audioService.play();
      await _storageService.saveLastPlayed(song.id);
      await _storageService.saveLastPlayedIndex(index);
    } catch (e) {
      _errorMessage = 'Không thể phát: ${song.title}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> playPause() async {
    if (_audioService.isPlaying) {
      await _audioService.pause();
    } else {
      await _audioService.play();
    }
    notifyListeners();
  }

  Future<void> play() async {
    await _audioService.play();
    notifyListeners();
  }

  Future<void> pause() async {
    await _audioService.pause();
    notifyListeners();
  }

  Future<void> stop() async {
    await _audioService.stop();
    notifyListeners();
  }

  Future<void> next() async {
    if (_queue.isEmpty) return;

    if (_isShuffleEnabled) {
      _shuffleHistory.add(_currentIndex);
      final nextIndex = _getRandomIndex();
      await _playSongAtIndex(nextIndex);
    } else {
      final nextIndex = (_currentIndex + 1) % _queue.length;
      await _playSongAtIndex(nextIndex);
    }
  }

  Future<void> previous() async {
    if (_queue.isEmpty) return;

    if (_audioService.currentPosition.inSeconds > 3) {
      await _audioService.seek(Duration.zero);
      return;
    }

    if (_isShuffleEnabled && _shuffleHistory.isNotEmpty) {
      final prevIndex = _shuffleHistory.removeLast();
      await _playSongAtIndex(prevIndex);
    } else {
      final prevIndex = (_currentIndex - 1 + _queue.length) % _queue.length;
      await _playSongAtIndex(prevIndex);
    }
  }

  Future<void> seek(Duration position) async {
    await _audioService.seek(position);
  }

  Future<void> toggleShuffle() async {
    _isShuffleEnabled = !_isShuffleEnabled;
    _shuffleHistory.clear();
    await _storageService.saveShuffleState(_isShuffleEnabled);
    notifyListeners();
  }

  Future<void> toggleRepeat() async {
    switch (_loopMode) {
      case LoopMode.off:
        _loopMode = LoopMode.all;
        break;
      case LoopMode.all:
        _loopMode = LoopMode.one;
        break;
      case LoopMode.one:
        _loopMode = LoopMode.off;
        break;
    }
    await _audioService.setLoopMode(_loopMode);
    await _storageService.saveRepeatMode(_loopMode.index);
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _audioService.setVolume(_volume);
    await _storageService.saveVolume(_volume);
    notifyListeners();
  }

  Future<void> setSpeed(double speed) async {
    _speed = speed.clamp(0.25, 3.0);
    await _audioService.setSpeed(_speed);
    notifyListeners();
  }

  void setSleepTimer(Duration duration) {
    _sleepTimer?.cancel();
    _sleepTimerRemaining = duration;
    notifyListeners();

    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_sleepTimerRemaining == null) {
        timer.cancel();
        return;
      }
      _sleepTimerRemaining =
          _sleepTimerRemaining! - const Duration(seconds: 1);
      if (_sleepTimerRemaining!.inSeconds <= 0) {
        timer.cancel();
        _sleepTimerRemaining = null;
        await pause();
      }
      notifyListeners();
    });
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimerRemaining = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  int _getRandomIndex() {
    if (_queue.length == 1) return 0;
    int next;
    do {
      next = _random.nextInt(_queue.length);
    } while (next == _currentIndex && _queue.length > 1);
    return next;
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _audioService.dispose();
    super.dispose();
  }
}