class Playlist {
  final String id;
  final String name;
  final int trackCount;
  final int totalDurationMs;
  final String? customArtworkPath;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isSmart;

  const Playlist({
    required this.id,
    required this.name,
    this.trackCount = 0,
    this.totalDurationMs = 0,
    this.customArtworkPath,
    required this.createdAt,
    this.updatedAt,
    this.isSmart = false,
  });

  Playlist copyWith({
    String? id,
    String? name,
    int? trackCount,
    int? totalDurationMs,
    String? customArtworkPath,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSmart,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      trackCount: trackCount ?? this.trackCount,
      totalDurationMs: totalDurationMs ?? this.totalDurationMs,
      customArtworkPath: customArtworkPath ?? this.customArtworkPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSmart: isSmart ?? this.isSmart,
    );
  }
}
