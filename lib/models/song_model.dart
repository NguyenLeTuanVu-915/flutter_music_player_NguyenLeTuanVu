class SongModel {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String filePath;
  final Duration? duration;
  final String? albumArt;
  final int? fileSize;
  final bool isAsset;

  const SongModel({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    required this.filePath,
    this.duration,
    this.albumArt,
    this.fileSize,
    this.isAsset = false,
  });

  SongModel copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? filePath,
    Duration? duration,
    String? albumArt,
    int? fileSize,
    bool? isAsset,
  }) {
    return SongModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      filePath: filePath ?? this.filePath,
      duration: duration ?? this.duration,
      albumArt: albumArt ?? this.albumArt,
      fileSize: fileSize ?? this.fileSize,
      isAsset: isAsset ?? this.isAsset,
    );
  }

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      album: json['album'] as String?,
      filePath: json['filePath'] as String,
      duration: json['duration'] != null
          ? Duration(milliseconds: json['duration'] as int)
          : null,
      albumArt: json['albumArt'] as String?,
      fileSize: json['fileSize'] as int?,
      isAsset: json['isAsset'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'filePath': filePath,
      'duration': duration?.inMilliseconds,
      'albumArt': albumArt,
      'fileSize': fileSize,
      'isAsset': isAsset,
    };
  }

  factory SongModel.fromAudioQuery(dynamic audioModel) {
    return SongModel(
      id: audioModel.id.toString(),
      title: audioModel.title as String,
      artist: audioModel.artist as String? ?? 'Unknown Artist',
      album: audioModel.album as String?,
      filePath: audioModel.data as String,
      duration: Duration(milliseconds: audioModel.duration as int? ?? 0),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SongModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'SongModel(id: $id, title: $title, artist: $artist)';
}