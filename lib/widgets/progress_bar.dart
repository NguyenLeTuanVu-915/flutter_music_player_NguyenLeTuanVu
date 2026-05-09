import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/duration_formatter.dart';

class ProgressBarWidget extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;

  const ProgressBarWidget({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  @override
  State<ProgressBarWidget> createState() => _ProgressBarWidgetState();
}

class _ProgressBarWidgetState extends State<ProgressBarWidget> {
  bool _isDragging = false;
  double _dragValue = 0.0;

  double get _progress {
    if (_isDragging) return _dragValue;
    if (widget.duration.inMilliseconds <= 0) return 0.0;
    return (widget.position.inMilliseconds / widget.duration.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  Duration get _displayPosition {
    if (_isDragging) {
      return Duration(
        milliseconds:
        (_dragValue * widget.duration.inMilliseconds).round(),
      );
    }
    return widget.position;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSlider(),
        const SizedBox(height: 4),
        _buildTimeLabels(),
      ],
    );
  }

  Widget _buildSlider() {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 3.5,
        thumbShape: _CustomThumbShape(),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
        activeTrackColor: Theme.of(context).colorScheme.primary,
        inactiveTrackColor: Colors.white.withOpacity(0.15),
        thumbColor: Colors.white,
        overlayColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        trackShape: const RoundedRectSliderTrackShape(),
      ),
      child: Slider(
        value: _progress,
        min: 0.0,
        max: 1.0,
        onChangeStart: (value) {
          setState(() {
            _isDragging = true;
            _dragValue = value;
          });
        },
        onChanged: (value) {
          setState(() => _dragValue = value);
        },
        onChangeEnd: (value) {
          final seekPosition = Duration(
            milliseconds: (value * widget.duration.inMilliseconds).round(),
          );
          widget.onSeek(seekPosition);
          setState(() => _isDragging = false);
        },
      ),
    );
  }

  Widget _buildTimeLabels() {
    final remaining = widget.duration - _displayPosition;
    final clampedRemaining =
    remaining.isNegative ? Duration.zero : remaining;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 100),
            child: Text(
              DurationFormatter.format(_displayPosition),
              key: ValueKey(_displayPosition.inSeconds),
              style: TextStyle(
                color: _isDragging
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white.withOpacity(0.45),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 100),
            child: Text(
              '-${DurationFormatter.format(clampedRemaining)}',
              key: ValueKey(clampedRemaining.inSeconds),
              style: TextStyle(
                color: Colors.white.withOpacity(0.35),
                fontSize: 11,
                fontWeight: FontWeight.w500,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomThumbShape extends SliderComponentShape {
  final double thumbRadius;
  final double activeThumbRadius;

  _CustomThumbShape({
    this.thumbRadius = 5.0,
    this.activeThumbRadius = 8.0,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(activeThumbRadius);
  }

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow,
      }) {
    final canvas = context.canvas;

    final currentRadius = Tween<double>(
      begin: thumbRadius,
      end: activeThumbRadius,
    ).evaluate(activationAnimation);

    final shadowPaint = Paint()
      ..color = (sliderTheme.activeTrackColor ?? AppColors.primary).withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(center, currentRadius + 2, shadowPaint);

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, currentRadius, paint);
  }
}