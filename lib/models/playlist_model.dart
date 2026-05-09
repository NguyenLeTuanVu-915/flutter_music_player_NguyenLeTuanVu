class PlaylistModel {
  final String id;
  final String name;
  final List<String> songIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? coverImage;

  const PlaylistModel({
    required this.id,
    required this.name,
    required this.songIds,
    required this.createdAt,
    required this.updatedAt,
    this.coverImage,
  });

  int get songCount => songIds.length;

  bool containsSong(String songId) => songIds.contains(songId);

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      id: json['id'] as String,
      name: json['name'] as String,
      songIds: List<String>.from(json['songIds'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      coverImage: json['coverImage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'songIds': songIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'coverImage': coverImage,
    };
  }

  PlaylistModel copyWith({
    String? name,
    List<String>? songIds,
    DateTime? updatedAt,
    String? coverImage,
  }) {
    return PlaylistModel(
      id: id,
      name: name ?? this.name,
      songIds: songIds ?? List<String>.from(this.songIds),
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      coverImage: coverImage ?? this.coverImage,
    );
  }

  PlaylistModel withAddedSong(String songId) {
    if (songIds.contains(songId)) return this;
    return copyWith(
      songIds: [...songIds, songId],
      updatedAt: DateTime.now(),
    );
  }

  PlaylistModel withRemovedSong(String songId) {
    return copyWith(
      songIds: songIds.where((id) => id != songId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlaylistModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'PlaylistModel(id: $id, name: $name, songs: ${songIds.length})';
}