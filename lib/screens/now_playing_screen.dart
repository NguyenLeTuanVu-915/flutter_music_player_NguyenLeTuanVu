import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/playback_state_model.dart';
import '../providers/audio_provider.dart';
import '../providers/playlist_provider.dart';
import '../widgets/album_art.dart';
import '../widgets/player_controls.dart';
import '../widgets/progress_bar.dart';
import '../utils/constants.dart';
import '../utils/duration_formatter.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  bool _wasPlaying = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _syncRotation(bool isPlaying) {
    if (isPlaying && !_wasPlaying) {
      _rotationController.repeat();
    } else if (!isPlaying && _wasPlaying) {
      _rotationController.stop();
    }
    _wasPlaying = isPlaying;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, provider, child) {
        final song = provider.currentSong;
        if (song == null) {
          return const Scaffold(
            body: Center(child: Text('Không có bài nào đang phát')),
          );
        }

        return StreamBuilder<PlaybackState>(
          stream: provider.playbackStateStream,
          builder: (context, snapshot) {
            final state = snapshot.data ?? PlaybackState.empty;
            _syncRotation(state.isPlaying);

            return Scaffold(
              backgroundColor: AppColors.background,
              body: SafeArea(
                child: Column(
                  children: [
                    _buildTopBar(context, provider),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: Column(
                            children: [
                              const SizedBox(height: 12),
                              _buildAlbumArt(song.albumArt),
                              const SizedBox(height: 32),
                              _buildSongInfo(context, provider, song.title,
                                  song.artist, song.album),
                              const SizedBox(height: 28),
                              ProgressBarWidget(
                                position: state.position,
                                duration: state.duration,
                                onSeek: provider.seek,
                              ),
                              const SizedBox(height: 8),
                              PlayerControls(provider: provider),
                              const SizedBox(height: 20),
                              _buildVolumeRow(context, provider, state.volume),
                              const SizedBox(height: 16),
                              _buildBottomRow(context, provider),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, AudioProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: Colors.white, size: 32),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'ĐANG PHÁT',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 2),
                StreamBuilder<bool>(
                  stream: provider.playingStream,
                  builder: (context, snapshot) {
                    final isPlaying = snapshot.data ?? false;
                    return Text(
                      isPlaying ? '▶  Đang phát' : '⏸  Tạm dừng',
                      style: TextStyle(
                        color: isPlaying
                            ? AppColors.primary
                            : Colors.white.withOpacity(0.4),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.more_vert_rounded,
                color: Colors.white.withOpacity(0.7)),
            onPressed: () => _showOptionsSheet(context, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(String? albumArt) {
    return Center(
      child: AnimatedBuilder(
        animation: _rotationController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationController.value * 2 * 3.14159265,
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 40,
                spreadRadius: 4,
              ),
            ],
          ),
          child: AlbumArt(
            albumArt: albumArt,
            size: 260,
            borderRadius: 130,
          ),
        ),
      ),
    );
  }

  Widget _buildSongInfo(
      BuildContext context,
      AudioProvider provider,
      String title,
      String artist,
      String? album,
      ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                artist,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (album != null && album.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  album,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        _AddToPlaylistButton(provider: provider),
      ],
    );
  }

  Widget _buildVolumeRow(
      BuildContext context, AudioProvider provider, double volume) {
    return Row(
      children: [
        Icon(Icons.volume_mute_rounded,
            color: Colors.white.withOpacity(0.4), size: 18),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: Colors.white.withOpacity(0.8),
              inactiveTrackColor: Colors.white.withOpacity(0.15),
              thumbColor: Colors.white,
            ),
            child: Slider(
              value: volume.clamp(0.0, 1.0),
              min: 0.0,
              max: 1.0,
              onChanged: provider.setVolume,
            ),
          ),
        ),
        Icon(Icons.volume_up_rounded,
            color: Colors.white.withOpacity(0.4), size: 18),
      ],
    );
  }

  Widget _buildBottomRow(BuildContext context, AudioProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _BottomIconButton(
          icon: Icons.timer_outlined,
          isActive: provider.sleepTimerRemaining != null,
          label: provider.sleepTimerRemaining != null
              ? DurationFormatter.formatShort(provider.sleepTimerRemaining!)
              : null,
          onTap: () => _showSleepTimerDialog(context, provider),
        ),
        _BottomIconButton(
          icon: Icons.queue_music_rounded,
          label: '${provider.queue.length}',
          onTap: () => _showQueueSheet(context, provider),
        ),
        _BottomIconButton(
          icon: Icons.stop_circle_outlined,
          onTap: () {
            provider.stop();
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  void _showOptionsSheet(BuildContext context, AudioProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('Thông tin bài hát'),
              onTap: () {
                Navigator.pop(context);
                _showSongInfoDialog(context, provider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: const Text('Hẹn giờ tắt'),
              onTap: () {
                Navigator.pop(context);
                _showSleepTimerDialog(context, provider);
              },
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  void _showSongInfoDialog(BuildContext context, AudioProvider provider) {
    final song = provider.currentSong;
    if (song == null) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông tin bài hát'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow(label: 'Tên', value: song.title),
            _InfoRow(label: 'Nghệ sĩ', value: song.artist),
            if (song.album != null) _InfoRow(label: 'Album', value: song.album!),
            if (song.duration != null)
              _InfoRow(
                  label: 'Thời lượng',
                  value: DurationFormatter.format(song.duration!)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showSleepTimerDialog(BuildContext context, AudioProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hẹn giờ tắt'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (provider.sleepTimerRemaining != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timer, color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Còn lại: ${DurationFormatter.format(provider.sleepTimerRemaining!)}',
                      style: const TextStyle(
                          color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [15, 30, 45, 60].map((min) {
                return ElevatedButton(
                  onPressed: () {
                    provider.setSleepTimer(Duration(minutes: min));
                    Navigator.pop(context);
                  },
                  child: Text('$min phút'),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          if (provider.sleepTimerRemaining != null)
            TextButton(
              onPressed: () {
                provider.cancelSleepTimer();
                Navigator.pop(context);
              },
              child: const Text('Huỷ hẹn giờ',
                  style: TextStyle(color: Colors.redAccent)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showQueueSheet(BuildContext context, AudioProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Text(
                        'Danh sách phát',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${provider.queue.length} bài',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.4), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: provider.queue.length,
                    itemBuilder: (context, index) {
                      final song = provider.queue[index];
                      final isCurrent = provider.currentIndex == index;
                      return ListTile(
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20),
                        leading: isCurrent
                            ? const Icon(Icons.equalizer_rounded,
                            color: AppColors.primary)
                            : Text(
                          '${index + 1}',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 13),
                        ),
                        title: Text(
                          song.title,
                          style: TextStyle(
                            color: isCurrent
                                ? AppColors.primary
                                : Colors.white,
                            fontWeight: isCurrent
                                ? FontWeight.w700
                                : FontWeight.w400,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          song.artist,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          provider.setPlaylist(provider.queue, index);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _AddToPlaylistButton extends StatelessWidget {
  final AudioProvider provider;
  const _AddToPlaylistButton({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, playlistProvider, child) {
        return IconButton(
          onPressed: () => _showAddToPlaylist(context, playlistProvider),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.playlist_add_rounded,
              color: Colors.white.withOpacity(0.7),
              size: 20,
            ),
          ),
        );
      },
    );
  }

  void _showAddToPlaylist(
      BuildContext context, PlaylistProvider playlistProvider) {
    final song = provider.currentSong;
    if (song == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'Thêm vào playlist',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
            ),
            if (playlistProvider.playlists.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Chưa có playlist nào',
                  style: TextStyle(color: Colors.white.withOpacity(0.4)),
                ),
              )
            else
              ...playlistProvider.playlists.map((playlist) {
                final alreadyIn = playlist.containsSong(song.id);
                return ListTile(
                  leading: Icon(
                    alreadyIn
                        ? Icons.check_circle_rounded
                        : Icons.playlist_play_rounded,
                    color: alreadyIn ? AppColors.primary : Colors.white54,
                  ),
                  title: Text(
                    playlist.name,
                    style: TextStyle(
                        color: alreadyIn ? AppColors.primary : Colors.white),
                  ),
                  subtitle: Text(
                    '${playlist.songCount} bài',
                    style: TextStyle(color: Colors.white.withOpacity(0.4)),
                  ),
                  onTap: alreadyIn
                      ? null
                      : () {
                    playlistProvider.addSongToPlaylist(playlist.id, song);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                          Text('Đã thêm vào "${playlist.name}"')),
                    );
                  },
                );
              }),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

class _BottomIconButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final String? label;
  final VoidCallback onTap;

  const _BottomIconButton({
    required this.icon,
    required this.onTap,
    this.isActive = false,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary.withOpacity(0.15)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isActive ? AppColors.primary : Colors.white.withOpacity(0.6),
              size: 22,
            ),
          ),
          if (label != null) ...[
            const SizedBox(height: 4),
            Text(
              label!,
              style: TextStyle(
                color: isActive ? AppColors.primary : Colors.white.withOpacity(0.4),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}