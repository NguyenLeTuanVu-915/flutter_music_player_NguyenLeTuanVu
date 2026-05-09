import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../providers/playlist_provider.dart';
import '../widgets/song_tile.dart';
import '../widgets/album_art.dart';
import '../utils/constants.dart';

class AllSongsScreen extends StatefulWidget {
  final List<SongModel> songs;
  final String title;

  const AllSongsScreen({
    super.key,
    required this.songs,
    this.title = 'Tất cả bài hát',
  });

  @override
  State<AllSongsScreen> createState() => _AllSongsScreenState();
}

class _AllSongsScreenState extends State<AllSongsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<SongModel> _filtered = [];
  Map<String, List<SongModel>> _grouped = {};
  List<String> _letters = [];
  bool _showAlphaScroller = true;

  @override
  void initState() {
    super.initState();
    _filtered = List.from(widget.songs);
    _buildGrouped();
    _searchController.addListener(() => _applyFilter(_searchController.text));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilter(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filtered = List.from(widget.songs);
        _showAlphaScroller = true;
      } else {
        final lower = query.toLowerCase().trim();
        _filtered = widget.songs.where((s) {
          return s.title.toLowerCase().contains(lower) ||
              s.artist.toLowerCase().contains(lower) ||
              (s.album?.toLowerCase().contains(lower) ?? false);
        }).toList();
        _showAlphaScroller = false;
      }
      _buildGrouped();
    });
  }

  void _buildGrouped() {
    _grouped = {};
    for (final song in _filtered) {
      final firstChar = song.title.isNotEmpty
          ? song.title[0].toUpperCase()
          : '#';
      final key = RegExp(r'[A-Z]').hasMatch(firstChar) ? firstChar : '#';
      _grouped.putIfAbsent(key, () => []).add(song);
    }
    _letters = _grouped.keys.toList()..sort();
    if (_letters.contains('#')) {
      _letters.remove('#');
      _letters.add('#');
    }
  }

  void _scrollToLetter(String letter) {
    double offset = 0;
    for (final key in _letters) {
      if (key == letter) break;
      offset += 36;
      offset += (_grouped[key]?.length ?? 0) * 72.0;
    }
    _scrollController.animateTo(
      offset.clamp(0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shuffle_rounded,
                color: Colors.white.withOpacity(0.7)),
            onPressed: _shuffleAll,
            tooltip: 'Phát ngẫu nhiên',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Tìm trong danh sách...',
                prefixIcon: const Icon(Icons.search_rounded,
                    color: Colors.white38, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: Colors.white38, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    _applyFilter('');
                    FocusScope.of(context).unfocus();
                  },
                )
                    : null,
              ),
            ),
          ),
        ),
      ),
      body: _filtered.isEmpty
          ? _buildEmpty()
          : Row(
        children: [
          Expanded(child: _buildList()),
          if (_showAlphaScroller) _buildAlphaScroller(),
        ],
      ),
    );
  }

  Widget _buildList() {
    final audioProvider = context.watch<AudioProvider>();
    final items = <Widget>[];

    for (final letter in _letters) {
      final songs = _grouped[letter] ?? [];
      items.add(_buildLetterHeader(letter));
      for (int i = 0; i < songs.length; i++) {
        final song = songs[i];
        final globalIndex = _filtered.indexOf(song);
        final isPlaying = audioProvider.currentSong?.id == song.id;
        items.add(
          SongTile(
            song: song,
            isPlaying: isPlaying,
            onTap: () => audioProvider.setPlaylist(_filtered, globalIndex),
            onLongPress: () => _showSongOptions(context, song),
          ),
        );
      }
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(
        bottom: kBottomNavigationBarHeight + 88,
      ),
      itemCount: items.length,
      itemBuilder: (_, index) => items[index],
    );
  }

  Widget _buildLetterHeader(String letter) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.centerLeft,
      child: Text(
        letter,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildAlphaScroller() {
    return SizedBox(
      width: 24,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _letters.map((letter) {
          return GestureDetector(
            onTap: () => _scrollToLetter(letter),
            child: SizedBox(
              height: 20,
              child: Center(
                child: Text(
                  letter,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded,
              size: 56, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy kết quả',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _shuffleAll() {
    if (_filtered.isEmpty) return;
    final provider = context.read<AudioProvider>();
    if (!provider.isShuffleEnabled) provider.toggleShuffle();
    provider.setPlaylist(_filtered, 0);
    Navigator.pop(context);
  }

  void _showSongOptions(BuildContext context, SongModel song) {
    final playlistProvider = context.read<PlaylistProvider>();
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
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AlbumArt(
                albumArt: song.albumArt,
                size: 48,
                borderRadius: 8,
              ),
            ),
            title: Text(
              song.title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              song.artist,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.4), fontSize: 12),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.play_arrow_rounded),
            title: const Text('Phát ngay'),
            onTap: () {
              final index = _filtered.indexOf(song);
              context.read<AudioProvider>().setPlaylist(_filtered, index);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.playlist_add_rounded),
            title: const Text('Thêm vào playlist'),
            onTap: () {
              Navigator.pop(context);
              _showAddToPlaylist(context, song, playlistProvider);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showAddToPlaylist(
      BuildContext context,
      SongModel song,
      PlaylistProvider playlistProvider,
      ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
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
              'Chọn playlist',
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
                  style:
                  TextStyle(color: Colors.white.withOpacity(0.4)),
                ),
                onTap: alreadyIn
                    ? null
                    : () {
                  playlistProvider.addSongToPlaylist(playlist.id, song);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                      Text('Đã thêm vào "${playlist.name}"'),
                    ),
                  );
                },
              );
            }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}