class DurationFormatter {
  DurationFormatter._();

  static String format(Duration duration) {
    if (duration.isNegative || duration == Duration.zero) return '0:00';

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${_pad(minutes)}:${_pad(seconds)}';
    }
    return '$minutes:${_pad(seconds)}';
  }

  static String formatShort(Duration duration) {
    if (duration.isNegative || duration == Duration.zero) return '0:00';

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}g ${_pad(minutes)}p';
    }
    if (minutes > 0) {
      return '${minutes}p ${_pad(seconds)}s';
    }
    return '${seconds}s';
  }

  static String formatLong(Duration duration) {
    if (duration.isNegative || duration == Duration.zero) return '0 giây';

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    final parts = <String>[];
    if (hours > 0) parts.add('$hours giờ');
    if (minutes > 0) parts.add('$minutes phút');
    if (seconds > 0 && hours == 0) parts.add('$seconds giây');

    return parts.join(' ');
  }

  static String formatCountdown(Duration duration) {
    if (duration.isNegative || duration == Duration.zero) return '0:00';

    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${_pad(seconds)}';
  }

  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  static String formatTotalDuration(List<Duration> durations) {
    if (durations.isEmpty) return '0 giây';
    final total = durations.fold(
      Duration.zero,
          (prev, d) => prev + d,
    );
    return formatLong(total);
  }

  static String formatRemaining(Duration position, Duration total) {
    final remaining = total - position;
    if (remaining.isNegative) return '-0:00';
    return '-${format(remaining)}';
  }

  static String _pad(int value) => value.toString().padLeft(2, '0');
}