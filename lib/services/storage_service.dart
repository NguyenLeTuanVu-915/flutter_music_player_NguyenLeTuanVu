import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/playlist_model.dart';

class StorageService {
  static const String _playlistsKey = 'playlists';
  static const String _lastPlayedSongIdKey = 'last_played_song_id';
  static const String _lastPlayedIndexKey = 'last_played_index';
  static const String _shuffleKey = 'shuffle_enabled';
  static const String _repeatKey = 'repeat_mode';
  static const String _volumeKey = 'volume';
  static const String _lastPositionKey = 'last_position_ms';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<void> savePlaylists(List<PlaylistModel> playlists) async {
    final prefs = await _prefs;
    final encoded = json.encode(playlists.map((p) => p.toJson()).toList());
    await prefs.setString(_playlistsKey, encoded);
  }

  Future<List<PlaylistModel>> getPlaylists() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_playlistsKey);
    if (raw == null) return [];
    try {
      final List<dynamic> decoded = json.decode(raw);
      return decoded.map((e) => PlaylistModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveLastPlayed(String songId) async {
    final prefs = await _prefs;
    await prefs.setString(_lastPlayedSongIdKey, songId);
  }

  Future<String?> getLastPlayed() async {
    final prefs = await _prefs;
    return prefs.getString(_lastPlayedSongIdKey);
  }

  Future<void> saveLastPlayedIndex(int index) async {
    final prefs = await _prefs;
    await prefs.setInt(_lastPlayedIndexKey, index);
  }

  Future<int> getLastPlayedIndex() async {
    final prefs = await _prefs;
    return prefs.getInt(_lastPlayedIndexKey) ?? 0;
  }

  Future<void> saveLastPosition(int positionMs) async {
    final prefs = await _prefs;
    await prefs.setInt(_lastPositionKey, positionMs);
  }

  Future<int> getLastPosition() async {
    final prefs = await _prefs;
    return prefs.getInt(_lastPositionKey) ?? 0;
  }

  Future<void> saveShuffleState(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_shuffleKey, enabled);
  }

  Future<bool> getShuffleState() async {
    final prefs = await _prefs;
    return prefs.getBool(_shuffleKey) ?? false;
  }

  Future<void> saveRepeatMode(int mode) async {
    final prefs = await _prefs;
    await prefs.setInt(_repeatKey, mode);
  }

  Future<int> getRepeatMode() async {
    final prefs = await _prefs;
    return prefs.getInt(_repeatKey) ?? 0;
  }

  Future<void> saveVolume(double volume) async {
    final prefs = await _prefs;
    await prefs.setDouble(_volumeKey, volume.clamp(0.0, 1.0));
  }

  Future<double> getVolume() async {
    final prefs = await _prefs;
    return (prefs.getDouble(_volumeKey) ?? 1.0).clamp(0.0, 1.0);
  }

  Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}