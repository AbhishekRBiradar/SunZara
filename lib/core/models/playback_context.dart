enum PlaybackContextType {
  library,
  playlist,
  album,
  artist,
  folder,
  favorites,
  search,
}

enum RepeatMode {
  off,
  all,
  one,
}

class PlaybackContext {
  final PlaybackContextType type;
  final String id;
  final String name;

  const PlaybackContext({
    required this.type,
    required this.id,
    required this.name,
  });

  static const library = PlaybackContext(
    type: PlaybackContextType.library,
    id: 'library_all',
    name: 'Entire Library',
  );

  static const favorites = PlaybackContext(
    type: PlaybackContextType.favorites,
    id: 'favorites_all',
    name: 'Favorites',
  );

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'id': id,
      'name': name,
    };
  }

  factory PlaybackContext.fromMap(Map<String, dynamic> map) {
    return PlaybackContext(
      type: PlaybackContextType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => PlaybackContextType.library,
      ),
      id: map['id'] as String,
      name: map['name'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaybackContext &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          id == other.id;

  @override
  int get hashCode => Object.hash(type, id);
}
