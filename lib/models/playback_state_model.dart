class PlaybackState {
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final double volume;

  const PlaybackState({
    required this.position,
    required this.duration,
    required this.isPlaying,
    this.volume = 1.0,
  });

  double get progress {
    if (duration.inMilliseconds > 0) {
      return (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
    }
    return 0.0;
  }

  Duration get remaining {
    final diff = duration - position;
    return diff.isNegative ? Duration.zero : diff;
  }

  bool get isNearEnd =>
      duration.inSeconds > 0 &&
          remaining.inSeconds <= 5;

  PlaybackState copyWith({
    Duration? position,
    Duration? duration,
    bool? isPlaying,
    double? volume,
  }) {
    return PlaybackState(
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isPlaying: isPlaying ?? this.isPlaying,
      volume: volume ?? this.volume,
    );
  }

  static const PlaybackState empty = PlaybackState(
    position: Duration.zero,
    duration: Duration.zero,
    isPlaying: false,
    volume: 1.0,
  );

  @override
  String toString() =>
      'PlaybackState(position: $position, duration: $duration, '
          'isPlaying: $isPlaying, volume: $volume)';
}