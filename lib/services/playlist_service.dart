import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:on_audio_query/on_audio_query.dart' as aq;
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../models/song_model.dart';

class PlaylistService {
  final aq.OnAudioQuery? _audioQuery = kIsWeb ? null : aq.OnAudioQuery();

  Future<List<SongModel>> getAllSongs() async {
    if (kIsWeb) return _getAssetSongs();

    try {
      if (_audioQuery == null) return _getAssetSongs();

      final audioList = await _audioQuery.querySongs(
        sortType: aq.SongSortType.TITLE,
        orderType: aq.OrderType.ASC_OR_SMALLER,
        uriType: aq.UriType.EXTERNAL,
        ignoreCase: true,
      );

      final validSongs = audioList
          .where((audio) =>
      audio.duration != null &&
          audio.duration! > 10000 &&
          audio.data.isNotEmpty &&
          File(audio.data).existsSync())
          .toList();

      if (validSongs.isEmpty) return _getAssetSongs();

      return validSongs.map((audio) => SongModel.fromAudioQuery(audio)).toList();
    } catch (_) {
      return _getAssetSongs();
    }
  }

  Future<List<SongModel>> pickSongsFromDevice() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) return [];

      return result.files
          .where((file) => file.path != null)
          .map((file) {
        final path = file.path!;
        final name = file.name;
        final nameWithoutExt = name.contains('.')
            ? name.substring(0, name.lastIndexOf('.'))
            : name;

        return SongModel(
          id: 'picked_${path.hashCode}',
          title: nameWithoutExt,
          artist: 'Unknown Artist',
          filePath: path,
          fileSize: file.size,
        );
      })
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<SongModel>> searchSongs(String query) async {
    if (query.trim().isEmpty) return getAllSongs();

    final allSongs = await getAllSongs();
    final lowerQuery = query.toLowerCase().trim();

    return allSongs.where((song) {
      return song.title.toLowerCase().contains(lowerQuery) ||
          song.artist.toLowerCase().contains(lowerQuery) ||
          (song.album?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  Future<List<SongModel>> getSongsByIds(List<String> ids) async {
    final allSongs = await getAllSongs();
    final idSet = ids.toSet();
    final map = {for (final s in allSongs) s.id: s};
    return ids
        .where((id) => idSet.contains(id) && map.containsKey(id))
        .map((id) => map[id]!)
        .toList();
  }

  List<SongModel> _getAssetSongs() {
    return [
      const SongModel(
        id: 'asset_1',
        title: '50 Năm Về Sau',
        artist: 'Đặng Thanh Tuyền',
        album: 'Album 1',
        filePath: 'assets/audio/sample_songs/50 Năm Về Sau.mp3',
        duration: Duration(minutes: 3, seconds: 30),
        isAsset: true,
      ),
      const SongModel(
        id: 'asset_2',
        title: 'Không Buông',
        artist: 'Hngle',
        album: 'Album 2',
        filePath: 'assets/audio/sample_songs/Không Buông.mp3',
        duration: Duration(minutes: 4, seconds: 15),
        isAsset: true,
      ),
      const SongModel(
        id: 'asset_3',
        title: 'Tuyển Bạn Gái',
        artist: 'Ogenus, Dangrangto',
        album: 'Album 3',
        filePath: 'assets/audio/sample_songs/Tuyển Bạn Gái.mp3',
        duration: Duration(minutes: 2, seconds: 50),
        isAsset: true,
      ),
    ];
  }
}