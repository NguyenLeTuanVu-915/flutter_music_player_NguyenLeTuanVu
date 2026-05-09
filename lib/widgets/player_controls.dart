import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../providers/audio_provider.dart';
import '../utils/constants.dart';

class PlayerControls extends StatelessWidget {
  final AudioProvider provider;

  const PlayerControls({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTopRow(context),
        const SizedBox(height: 20),
        _buildMainControls(context),
      ],
    );
  }

  Widget _buildTopRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildShuffleButton(),
        _buildRepeatButton(),
      ],
    );
  }

  Widget _buildShuffleButton() {
    final isActive = provider.isShuffleEnabled;
    return _IconToggleButton(
      icon: Icons.shuffle_rounded,
      isActive: isActive,
      onTap: provider.toggleShuffle,
      tooltip: isActive ? 'Tắt trộn bài' : 'Bật trộn bài',
    );
  }

  Widget _buildRepeatButton() {
    final loopMode = provider.loopMode;

    IconData icon;
    bool isActive;
    String tooltip;

    switch (loopMode) {
      case LoopMode.off:
        icon = Icons.repeat_rounded;
        isActive = false;
        tooltip = 'Lặp lại: Tắt';
        break;
      case LoopMode.all:
        icon = Icons.repeat_rounded;
        isActive = true;
        tooltip = 'Lặp lại: Tất cả';
        break;
      case LoopMode.one:
        icon = Icons.repeat_one_rounded;
        isActive = true;
        tooltip = 'Lặp lại: Một bài';
        break;
    }

    return _IconToggleButton(
      icon: icon,
      isActive: isActive,
      onTap: provider.toggleRepeat,
      tooltip: tooltip,
    );
  }

  Widget _buildMainControls(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildPreviousButton(),
        _buildPlayPauseButton(),
        _buildNextButton(),
      ],
    );
  }

  Widget _buildPreviousButton() {
    return _NavButton(
      icon: Icons.skip_previous_rounded,
      size: 38,
      onTap: provider.previous,
      tooltip: 'Bài trước',
    );
  }

  Widget _buildNextButton() {
    return _NavButton(
      icon: Icons.skip_next_rounded,
      size: 38,
      onTap: provider.next,
      tooltip: 'Bài tiếp',
    );
  }

  Widget _buildPlayPauseButton() {
    return StreamBuilder<bool>(
      stream: provider.playingStream,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data ?? false;
        return _PlayPauseButton(
          isPlaying: isPlaying,
          isLoading: provider.isLoading,
          onTap: provider.playPause,
        );
      },
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onTap;

  const _PlayPauseButton({
    required this.isPlaying,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.45),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isLoading
            ? const Center(
          child: SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
              color: Colors.black,
              strokeWidth: 2.5,
            ),
          ),
        )
            : AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: animation,
            child: child,
          ),
          child: Icon(
            isPlaying
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
            key: ValueKey(isPlaying),
            color: Colors.black,
            size: 38,
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;
  final String tooltip;

  const _NavButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: AppColors.primary.withOpacity(0.15),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(
              icon,
              color: Colors.white,
              size: size,
            ),
          ),
        ),
      ),
    );
  }
}

class _IconToggleButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final String tooltip;

  const _IconToggleButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withOpacity(0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                color: isActive
                    ? AppColors.primary
                    : Colors.white.withOpacity(0.4),
                size: 22,
              ),
              if (isActive)
                Positioned(
                  bottom: -3,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}