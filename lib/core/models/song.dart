class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String? albumArtist;
  final String? genre;
  final int? year;
  final int? trackNumber;
  final int durationMs;
  final int fileSize;
  final String filePath;
  final String folder;
  final DateTime? dateAdded;
  final DateTime? dateModified;
  final String? artworkUri;
  final String? lrcPath;
  final bool isFavorite;
  final int playCount;
  final DateTime? lastPlayed;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    this.albumArtist,
    this.genre,
    this.year,
    this.trackNumber,
    required this.durationMs,
    required this.fileSize,
    required this.filePath,
    required this.folder,
    this.dateAdded,
    this.dateModified,
    this.artworkUri,
    this.lrcPath,
    this.isFavorite = false,
    this.playCount = 0,
    this.lastPlayed,
  });

  String get formattedDuration {
    final totalSeconds = (durationMs / 1000).round();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  bool get isOnline =>
      filePath.startsWith('yt:') ||
      filePath.startsWith('http://') ||
      filePath.startsWith('https://');

  bool get isOffline => !isOnline;

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? albumArtist,
    String? genre,
    int? year,
    int? trackNumber,
    int? durationMs,
    int? fileSize,
    String? filePath,
    String? folder,
    DateTime? dateAdded,
    DateTime? dateModified,
    String? artworkUri,
    String? lrcPath,
    bool? isFavorite,
    int? playCount,
    DateTime? lastPlayed,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumArtist: albumArtist ?? this.albumArtist,
      genre: genre ?? this.genre,
      year: year ?? this.year,
      trackNumber: trackNumber ?? this.trackNumber,
      durationMs: durationMs ?? this.durationMs,
      fileSize: fileSize ?? this.fileSize,
      filePath: filePath ?? this.filePath,
      folder: folder ?? this.folder,
      dateAdded: dateAdded ?? this.dateAdded,
      dateModified: dateModified ?? this.dateModified,
      artworkUri: artworkUri ?? this.artworkUri,
      lrcPath: lrcPath ?? this.lrcPath,
      isFavorite: isFavorite ?? this.isFavorite,
      playCount: playCount ?? this.playCount,
      lastPlayed: lastPlayed ?? this.lastPlayed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'albumArtist': albumArtist,
      'genre': genre,
      'year': year,
      'trackNumber': trackNumber,
      'durationMs': durationMs,
      'fileSize': fileSize,
      'filePath': filePath,
      'folder': folder,
      'dateAdded': dateAdded?.toIso8601String(),
      'dateModified': dateModified?.toIso8601String(),
      'artworkUri': artworkUri,
      'lrcPath': lrcPath,
      'isFavorite': isFavorite ? 1 : 0,
      'playCount': playCount,
      'lastPlayed': lastPlayed?.toIso8601String(),
    };
  }

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'] as String,
      title: map['title'] as String,
      artist: map['artist'] as String,
      album: map['album'] as String,
      albumArtist: map['albumArtist'] as String?,
      genre: map['genre'] as String?,
      year: map['year'] as int?,
      trackNumber: map['trackNumber'] as int?,
      durationMs: map['durationMs'] as int,
      fileSize: map['fileSize'] as int,
      filePath: map['filePath'] as String,
      folder: map['folder'] as String,
      dateAdded: map['dateAdded'] != null ? DateTime.tryParse(map['dateAdded'] as String) : null,
      dateModified: map['dateModified'] != null ? DateTime.tryParse(map['dateModified'] as String) : null,
      artworkUri: map['artworkUri'] as String?,
      lrcPath: map['lrcPath'] as String?,
      isFavorite: (map['isFavorite'] == 1 || map['isFavorite'] == true),
      playCount: (map['playCount'] as int?) ?? 0,
      lastPlayed: map['lastPlayed'] != null ? DateTime.tryParse(map['lastPlayed'] as String) : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
