import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/playlist_model.dart';
import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../providers/playlist_provider.dart';
import '../services/playlist_service.dart';
import '../widgets/album_art.dart';
import '../widgets/song_tile.dart';
import '../utils/constants.dart';
import 'now_playing_screen.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thư viện',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Playlist',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showCreateDialog(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_rounded,
                  color: AppColors.primary, size: 20),
            ),
            tooltip: 'Tạo playlist mới',
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (provider.playlists.isEmpty) return _buildEmpty(context);

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.72,
          ),
          itemCount: provider.playlists.length,
          itemBuilder: (context, index) {
            return _PlaylistCard(
              playlist: provider.playlists[index],
              onTap: () => _openPlaylist(context, provider.playlists[index]),
              onLongPress: () =>
                  _showPlaylistOptions(context, provider.playlists[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.library_music_outlined,
                  size: 56, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            const Text(
              'Chưa có playlist',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              'Tạo playlist để quản lý nhạc của bạn',
              textAlign: TextAlign.center,
              style:
              TextStyle(color: Colors.white.withOpacity(0.5), height: 1.5),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => _showCreateDialog(context),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Tạo playlist'),
            ),
          ],
        ),
      ),
    );
  }

  void _openPlaylist(BuildContext context, PlaylistModel playlist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistDetailScreen(playlist: playlist),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo playlist mới'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Tên playlist'),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              context.read<PlaylistProvider>().createPlaylist(value.trim());
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context
                    .read<PlaylistProvider>()
                    .createPlaylist(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }

  void _showPlaylistOptions(BuildContext context, PlaylistModel playlist) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                const Icon(Icons.playlist_play_rounded, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  playlist.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Đổi tên'),
            onTap: () {
              Navigator.pop(context);
              _showRenameDialog(context, playlist);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded,
                color: Colors.redAccent),
            title: const Text('Xoá playlist',
                style: TextStyle(color: Colors.redAccent)),
            onTap: () {
              Navigator.pop(context);
              _confirmDelete(context, playlist);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, PlaylistModel playlist) {
    final controller = TextEditingController(text: playlist.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đổi tên playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Tên mới'),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              context
                  .read<PlaylistProvider>()
                  .renamePlaylist(playlist.id, value.trim());
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context
                    .read<PlaylistProvider>()
                    .renamePlaylist(playlist.id, controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, PlaylistModel playlist) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xoá playlist'),
        content: Text('Bạn có chắc muốn xoá "${playlist.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () {
              context.read<PlaylistProvider>().deletePlaylist(playlist.id);
              Navigator.pop(context);
            },
            child: const Text('Xoá',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  final PlaylistModel playlist;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _PlaylistCard({
    required this.playlist,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child: Stack(
                children: [
                  const AlbumArt(
                    albumArt: null,
                    size: double.infinity,
                    borderRadius: 0,
                    aspectRatio: 1.0,
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${playlist.songCount} bài',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${playlist.songCount} bài hát',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlaylistDetailScreen extends StatefulWidget {
  final PlaylistModel playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  final PlaylistService _playlistService = PlaylistService();
  List<SongModel> _songs = [];
  List<SongModel> _allSongs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    setState(() => _isLoading = true);
    final playlist = context
        .read<PlaylistProvider>()
        .getPlaylistById(widget.playlist.id) ??
        widget.playlist;
    final songs =
    await _playlistService.getSongsByIds(playlist.songIds);
    _allSongs = await _playlistService.getAllSongs();
    setState(() {
      _songs = songs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, playlistProvider, child) {
        final playlist =
            playlistProvider.getPlaylistById(widget.playlist.id) ??
                widget.playlist;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              _buildAppBar(context, playlist, playlistProvider),
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (_songs.isEmpty)
                SliverFillRemaining(child: _buildEmpty(context, playlist))
              else
                _buildSongList(playlist, playlistProvider),
            ],
          ),
          floatingActionButton: FloatingActionButton.small(
            onPressed: () => _showAddSongsSheet(context, playlist, playlistProvider),
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add_rounded, color: Colors.black),
          ),
        );
      },
    );
  }

  SliverAppBar _buildAppBar(
      BuildContext context,
      PlaylistModel playlist,
      PlaylistProvider playlistProvider,
      ) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: AppColors.background,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.more_vert_rounded,
              color: Colors.white.withOpacity(0.7)),
          onPressed: () =>
              _showDetailOptions(context, playlist, playlistProvider),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withOpacity(0.35),
                AppColors.background,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 48),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: const AlbumArt(
                  albumArt: null,
                  size: 120,
                  borderRadius: 16,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${playlist.songCount} bài hát',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        title: Text(playlist.name),
        titlePadding: const EdgeInsets.symmetric(horizontal: 56, vertical: 14),
      ),
    );
  }

  SliverList _buildSongList(
      PlaylistModel playlist, PlaylistProvider playlistProvider) {
    final audioProvider = context.read<AudioProvider>();
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          if (index == 0) return _buildPlayActions(audioProvider);
          final songIndex = index - 1;
          final song = _songs[songIndex];
          final isPlaying = audioProvider.currentSong?.id == song.id;
          return Dismissible(
            key: Key('${playlist.id}_${song.id}'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: Colors.redAccent.withOpacity(0.15),
              child:
              const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            ),
            onDismissed: (_) {
              playlistProvider.removeSongFromPlaylist(playlist.id, song.id);
              setState(() => _songs.removeAt(songIndex));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã xoá "${song.title}" khỏi playlist'),
                  action: SnackBarAction(
                    label: 'Hoàn tác',
                    onPressed: () {
                      playlistProvider.addSongToPlaylist(playlist.id, song);
                      _loadSongs();
                    },
                  ),
                ),
              );
            },
            child: SongTile(
              song: song,
              isPlaying: isPlaying,
              onTap: () => audioProvider.setPlaylist(_songs, songIndex),
            ),
          );
        },
        childCount: _songs.length + 1,
      ),
    );
  }

  Widget _buildPlayActions(AudioProvider audioProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_songs.isEmpty) return;
                audioProvider.setPlaylist(_songs, 0);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NowPlayingScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow_rounded,
                        size: 18, color: Colors.black),
                    SizedBox(width: 6),
                    Text(
                      'Phát',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_songs.isEmpty) return;
                if (!audioProvider.isShuffleEnabled) {
                  audioProvider.toggleShuffle();
                }
                audioProvider.setPlaylist(_songs, 0);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shuffle_rounded, size: 18, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'Trộn bài',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, PlaylistModel playlist) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.queue_music_rounded,
                size: 56, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 20),
            const Text(
              'Playlist trống',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Thêm bài hát vào playlist này',
              style: TextStyle(color: Colors.white.withOpacity(0.4)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddSongsSheet(
                  context,
                  playlist,
                  context.read<PlaylistProvider>()),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Thêm bài hát'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailOptions(
      BuildContext context,
      PlaylistModel playlist,
      PlaylistProvider playlistProvider,
      ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Đổi tên playlist'),
            onTap: () {
              Navigator.pop(context);
              _showRenameDialog(context, playlist, playlistProvider);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded,
                color: Colors.redAccent),
            title: const Text('Xoá playlist',
                style: TextStyle(color: Colors.redAccent)),
            onTap: () {
              Navigator.pop(context);
              _confirmDelete(context, playlist, playlistProvider);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showRenameDialog(
      BuildContext context,
      PlaylistModel playlist,
      PlaylistProvider provider,
      ) {
    final controller = TextEditingController(text: playlist.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đổi tên playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Tên mới'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                provider.renamePlaylist(playlist.id, controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context,
      PlaylistModel playlist,
      PlaylistProvider provider,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xoá playlist'),
        content: Text('Bạn có chắc muốn xoá "${playlist.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () {
              provider.deletePlaylist(playlist.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Xoá',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showAddSongsSheet(
      BuildContext context,
      PlaylistModel playlist,
      PlaylistProvider playlistProvider,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Column(
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
                  padding: EdgeInsets.fromLTRB(20, 14, 20, 8),
                  child: Row(
                    children: [
                      Text(
                        'Thêm bài hát',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Consumer<PlaylistProvider>(
                    builder: (context, liveProvider, child) {
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: _allSongs.length,
                        itemBuilder: (context, index) {
                          final song = _allSongs[index];
                          final currentPlaylist = liveProvider
                              .getPlaylistById(playlist.id) ??
                              playlist;
                          final alreadyIn =
                          currentPlaylist.containsSong(song.id);
                          return ListTile(
                            contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: AlbumArt(
                                albumArt: song.albumArt,
                                size: 44,
                                borderRadius: 8,
                              ),
                            ),
                            title: Text(
                              song.title,
                              style: TextStyle(
                                color: alreadyIn
                                    ? AppColors.primary
                                    : Colors.white,
                                fontSize: 14,
                                fontWeight: alreadyIn
                                    ? FontWeight.w600
                                    : FontWeight.w400,
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
                            trailing: alreadyIn
                                ? const Icon(Icons.check_circle_rounded,
                                color: AppColors.primary, size: 20)
                                : Icon(Icons.add_circle_outline_rounded,
                                color: Colors.white.withOpacity(0.4),
                                size: 20),
                            onTap: alreadyIn
                                ? null
                                : () async {
                              final added = await liveProvider
                                  .addSongToPlaylist(playlist.id, song);
                              if (added) await _loadSongs();
                            },
                          );
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