import 'package:flutter/material.dart';
import '../models/playlist_model.dart';
import '../models/song_model.dart';
import '../services/storage_service.dart';

class PlaylistProvider extends ChangeNotifier {
  final StorageService _storageService;

  List<PlaylistModel> _playlists = [];
  bool _isLoading = false;

  PlaylistProvider(this._storageService) {
    _loadPlaylists();
  }

  List<PlaylistModel> get playlists => List.unmodifiable(_playlists);
  bool get isLoading => _isLoading;
  bool get hasPlaylists => _playlists.isNotEmpty;

  PlaylistModel? getPlaylistById(String id) {
    try {
      return _playlists.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadPlaylists() async {
    _isLoading = true;
    notifyListeners();

    _playlists = await _storageService.getPlaylists();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => _loadPlaylists();

  Future<PlaylistModel> createPlaylist(String name) async {
    final playlist = PlaylistModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      songIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _playlists = [..._playlists, playlist];
    await _save();
    notifyListeners();
    return playlist;
  }

  Future<void> renamePlaylist(String playlistId, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;

    _playlists = _playlists.map((p) {
      if (p.id != playlistId) return p;
      return p.copyWith(name: trimmed, updatedAt: DateTime.now());
    }).toList();

    await _save();
    notifyListeners();
  }

  Future<void> deletePlaylist(String playlistId) async {
    _playlists = _playlists.where((p) => p.id != playlistId).toList();
    await _save();
    notifyListeners();
  }

  Future<bool> addSongToPlaylist(String playlistId, SongModel song) async {
    bool added = false;

    _playlists = _playlists.map((p) {
      if (p.id != playlistId) return p;
      if (p.containsSong(song.id)) return p;
      added = true;
      return p.withAddedSong(song.id);
    }).toList();

    if (added) {
      await _save();
      notifyListeners();
    }

    return added;
  }

  Future<void> removeSongFromPlaylist(
      String playlistId,
      String songId,
      ) async {
    _playlists = _playlists.map((p) {
      if (p.id != playlistId) return p;
      return p.withRemovedSong(songId);
    }).toList();

    await _save();
    notifyListeners();
  }

  Future<void> reorderSongInPlaylist(
      String playlistId,
      int oldIndex,
      int newIndex,
      ) async {
    _playlists = _playlists.map((p) {
      if (p.id != playlistId) return p;
      final ids = List<String>.from(p.songIds);
      final item = ids.removeAt(oldIndex);
      ids.insert(newIndex, item);
      return p.copyWith(songIds: ids, updatedAt: DateTime.now());
    }).toList();

    await _save();
    notifyListeners();
  }

  bool isSongInPlaylist(String playlistId, String songId) {
    return getPlaylistById(playlistId)?.containsSong(songId) ?? false;
  }

  Future<void> _save() async {
    await _storageService.savePlaylists(_playlists);
  }
}