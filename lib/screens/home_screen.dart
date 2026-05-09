import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../services/playlist_service.dart';
import '../services/permission_service.dart';
import '../widgets/song_tile.dart';
import '../utils/constants.dart';

enum SortOption { title, artist, album, duration }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PlaylistService _playlistService = PlaylistService();
  final PermissionService _permissionService = PermissionService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<SongModel> _allSongs = [];
  List<SongModel> _filteredSongs = [];
  bool _isLoading = true;
  bool _hasPermission = false;
  bool _isSearching = false;
  SortOption _currentSort = SortOption.title;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    _hasPermission = await _permissionService.requestStoragePermission();
    if (_hasPermission) {
      await _loadSongs();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSongs() async {
    setState(() => _isLoading = true);
    try {
      final songs = await _playlistService.getAllSongs();
      setState(() {
        _allSongs = songs;
        _filteredSongs = songs;
        _isLoading = false;
      });
      _applySort(_currentSort);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải nhạc: $e')),
        );
      }
    }
  }

  Future<void> _pickFromDevice() async {
    final picked = await _playlistService.pickSongsFromDevice();
    if (picked.isEmpty) return;
    setState(() {
      final existingIds = _allSongs.map((s) => s.id).toSet();
      final newSongs = picked.where((s) => !existingIds.contains(s.id)).toList();
      _allSongs = [..._allSongs, ...newSongs];
      _applyFilter(_searchController.text);
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã thêm ${picked.length} bài')),
      );
    }
  }

  void _applyFilter(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filteredSongs = List.from(_allSongs);
      } else {
        final lower = query.toLowerCase().trim();
        _filteredSongs = _allSongs.where((s) {
          return s.title.toLowerCase().contains(lower) ||
              s.artist.toLowerCase().contains(lower) ||
              (s.album?.toLowerCase().contains(lower) ?? false);
        }).toList();
      }
      _applySort(_currentSort);
    });
  }

  void _applySort(SortOption sort) {
    setState(() {
      _currentSort = sort;
      switch (sort) {
        case SortOption.title:
          _filteredSongs.sort((a, b) =>
              a.title.toLowerCase().compareTo(b.title.toLowerCase()));
          break;
        case SortOption.artist:
          _filteredSongs.sort((a, b) =>
              a.artist.toLowerCase().compareTo(b.artist.toLowerCase()));
          break;
        case SortOption.album:
          _filteredSongs.sort((a, b) =>
              (a.album ?? '').toLowerCase().compareTo(
                (b.album ?? '').toLowerCase(),
              ));
          break;
        case SortOption.duration:
          _filteredSongs.sort((a, b) =>
              (a.duration ?? Duration.zero).compareTo(
                b.duration ?? Duration.zero,
              ));
          break;
      }
    });
  }

  void _playAll() {
    if (_filteredSongs.isEmpty) return;
    context.read<AudioProvider>().setPlaylist(_filteredSongs, 0);
  }

  void _shuffleAll() {
    if (_filteredSongs.isEmpty) return;
    final provider = context.read<AudioProvider>();
    if (!provider.isShuffleEnabled) provider.toggleShuffle();
    provider.setPlaylist(_filteredSongs, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildActionRow(),
            _buildSortChips(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
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
                  'Nhạc của tôi',
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
            onPressed: _pickFromDevice,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            tooltip: 'Thêm nhạc từ thiết bị',
          ),
          IconButton(
            onPressed: _loadSongs,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.refresh_rounded,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
            ),
            tooltip: 'Tải lại',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: _searchController,
        onTap: () => setState(() => _isSearching = true),
        onChanged: _applyFilter,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Tìm bài hát, nghệ sĩ...',
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.white38, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white38, size: 18),
            onPressed: () {
              _searchController.clear();
              _applyFilter('');
              setState(() => _isSearching = false);
              FocusScope.of(context).unfocus();
            },
          )
              : null,
        ),
      ),
    );
  }

  Widget _buildActionRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              icon: Icons.play_arrow_rounded,
              label: 'Phát tất cả',
              onTap: _playAll,
              isPrimary: true,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ActionButton(
              icon: Icons.shuffle_rounded,
              label: 'Trộn bài',
              onTap: _shuffleAll,
              isPrimary: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChips() {
    final options = [
      (SortOption.title, 'Tên'),
      (SortOption.artist, 'Nghệ sĩ'),
      (SortOption.album, 'Album'),
      (SortOption.duration, 'Thời lượng'),
    ];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (option, label) = options[index];
          final isSelected = _currentSort == option;
          return GestureDetector(
            onTap: () => _applySort(option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (!_hasPermission) return _buildPermissionDenied();
    if (_allSongs.isEmpty) return _buildNoSongs();
    if (_filteredSongs.isEmpty) return _buildNoResults();
    return _buildSongList();
  }

  Widget _buildSongList() {
    final audioProvider = context.watch<AudioProvider>();
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.cardBackground,
      onRefresh: _loadSongs,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          top: 8,
          bottom: kBottomNavigationBarHeight + 88,
        ),
        itemCount: _filteredSongs.length,
        itemBuilder: (context, index) {
          final song = _filteredSongs[index];
          final isPlaying = audioProvider.currentSong?.id == song.id;
          return SongTile(
            song: song,
            isPlaying: isPlaying,
            onTap: () => audioProvider.setPlaylist(_filteredSongs, index),
          );
        },
      ),
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline_rounded,
                  size: 56, color: Colors.white38),
            ),
            const SizedBox(height: 24),
            const Text(
              'Cần quyền truy cập',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Cấp quyền truy cập bộ nhớ để đọc file nhạc trên thiết bị',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.5), height: 1.5),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () async {
                await _permissionService.openSettings();
                await _initializeApp();
              },
              icon: const Icon(Icons.settings_outlined, size: 18),
              label: const Text('Mở cài đặt'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSongs() {
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
              child: const Icon(Icons.music_note_rounded,
                  size: 56, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            const Text(
              'Chưa có nhạc',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Thêm file nhạc vào thiết bị hoặc chọn thủ công',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.5), height: 1.5),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _pickFromDevice,
              icon: const Icon(Icons.folder_open_rounded, size: 18),
              label: const Text('Chọn từ thiết bị'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults() {
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
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.primary
              : Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isPrimary ? Colors.black : Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.black : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}