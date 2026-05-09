import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import '../models/playback_state_model.dart';

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<bool> get playingStream => _audioPlayer.playingStream;
  Stream<double> get volumeStream => _audioPlayer.volumeStream;

  Duration get currentPosition => _audioPlayer.position;
  Duration? get currentDuration => _audioPlayer.duration;
  bool get isPlaying => _audioPlayer.playing;
  double get currentVolume => _audioPlayer.volume;

  Stream<PlaybackState> get playbackStateStream {
    return Rx.combineLatest4<Duration, Duration?, bool, double, PlaybackState>(
      positionStream,
      durationStream,
      playingStream,
      volumeStream,
          (position, duration, isPlaying, volume) => PlaybackState(
        position: position,
        duration: duration ?? Duration.zero,
        isPlaying: isPlaying,
        volume: volume,
      ),
    );
  }

  Future<void> loadAudio(String filePath) async {
    try {
      await _audioPlayer.setFilePath(filePath);
    } catch (e) {
      throw Exception('Không thể tải file âm thanh: $e');
    }
  }

  Future<void> loadAssetAudio(String assetPath) async {
    try {
      await _audioPlayer.setAsset(assetPath);
    } catch (e) {
      throw Exception('Không thể tải asset âm thanh: $e');
    }
  }

  Future<void> play() async {
    await _audioPlayer.play();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  Future<void> setSpeed(double speed) async {
    await _audioPlayer.setSpeed(speed.clamp(0.25, 3.0));
  }

  Future<void> setLoopMode(LoopMode loopMode) async {
    await _audioPlayer.setLoopMode(loopMode);
  }

  ProcessingState get processingState =>
      _audioPlayer.processingState;

  void dispose() {
    _audioPlayer.dispose();
  }
}