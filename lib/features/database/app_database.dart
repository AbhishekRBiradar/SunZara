import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import '../../core/models/playback_context.dart';
import '../../core/models/song.dart';
import '../../core/models/playlist.dart';

part 'app_database.g.dart';

class SongsTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get artist => text()();
  TextColumn get album => text()();
  TextColumn get albumArtist => text().nullable()();
  TextColumn get genre => text().nullable()();
  IntColumn get year => integer().nullable()();
  IntColumn get trackNumber => integer().nullable()();
  IntColumn get durationMs => integer()();
  IntColumn get fileSize => integer()();
  TextColumn get filePath => text()();
  TextColumn get folder => text()();
  DateTimeColumn get dateAdded => dateTime().nullable()();
  DateTimeColumn get dateModified => dateTime().nullable()();
  TextColumn get artworkUri => text().nullable()();
  TextColumn get lrcPath => text().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  IntColumn get playCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastPlayed => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class PlaylistsTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get customArtworkPath => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isSmart => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class PlaylistSongsTable extends Table {
  TextColumn get playlistId => text()();
  TextColumn get songId => text()();
  IntColumn get sortOrder => integer()();

  @override
  Set<Column> get primaryKey => {playlistId, songId};
}

class PlaybackStateTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get currentSongId => text().nullable()();
  IntColumn get positionMs => integer().withDefault(const Constant(0))();
  TextColumn get contextType => text().withDefault(const Constant('library'))();
  TextColumn get contextId => text().withDefault(const Constant('library_all'))();
  TextColumn get contextName => text().withDefault(const Constant('Entire Library'))();
  BoolColumn get isShuffleEnabled => boolean().withDefault(const Constant(true))();
  TextColumn get repeatMode => text().withDefault(const Constant('off'))();
  TextColumn get manualQueueJson => text().withDefault(const Constant('[]'))();
  TextColumn get automaticPoolJson => text().withDefault(const Constant('[]'))();
  TextColumn get shuffleStateJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get updatedAt => dateTime()();
}

@DriftDatabase(tables: [SongsTable, PlaylistsTable, PlaylistSongsTable, PlaybackStateTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? driftDatabase(name: 'sunzara_db'));

  @override
  int get schemaVersion => 1;

  // --- Song Operations ---

  Future<List<Song>> getAllSongs() async {
    final rows = await select(songsTable).get();
    return rows.map(_rowToSong).toList();
  }

  Stream<List<Song>> watchAllSongs() {
    return select(songsTable).watch().map((rows) => rows.map(_rowToSong).toList());
  }

  Future<Song?> getSongById(String id) async {
    final query = select(songsTable)..where((t) => t.id.equals(id));
    final row = await query.getSingleOrNull();
    return row != null ? _rowToSong(row) : null;
  }

  Future<void> insertOrUpdateSong(Song song) async {
    await into(songsTable).insertOnConflictUpdate(
      SongsTableCompanion(
        id: Value(song.id),
        title: Value(song.title),
        artist: Value(song.artist),
        album: Value(song.album),
        albumArtist: Value(song.albumArtist),
        genre: Value(song.genre),
        year: Value(song.year),
        trackNumber: Value(song.trackNumber),
        durationMs: Value(song.durationMs),
        fileSize: Value(song.fileSize),
        filePath: Value(song.filePath),
        folder: Value(song.folder),
        dateAdded: Value(song.dateAdded),
        dateModified: Value(song.dateModified),
        artworkUri: Value(song.artworkUri),
        lrcPath: Value(song.lrcPath),
        isFavorite: Value(song.isFavorite),
        playCount: Value(song.playCount),
        lastPlayed: Value(song.lastPlayed),
      ),
    );
  }

  Future<void> insertSongsBatch(List<Song> songs) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(
        songsTable,
        songs.map((song) => SongsTableCompanion(
              id: Value(song.id),
              title: Value(song.title),
              artist: Value(song.artist),
              album: Value(song.album),
              albumArtist: Value(song.albumArtist),
              genre: Value(song.genre),
              year: Value(song.year),
              trackNumber: Value(song.trackNumber),
              durationMs: Value(song.durationMs),
              fileSize: Value(song.fileSize),
              filePath: Value(song.filePath),
              folder: Value(song.folder),
              dateAdded: Value(song.dateAdded),
              dateModified: Value(song.dateModified),
              artworkUri: Value(song.artworkUri),
              lrcPath: Value(song.lrcPath),
              isFavorite: Value(song.isFavorite),
              playCount: Value(song.playCount),
              lastPlayed: Value(song.lastPlayed),
            )),
      );
    });
  }

  Future<void> deleteSong(String id) async {
    await (delete(songsTable)..where((t) => t.id.equals(id))).go();
    await (delete(playlistSongsTable)..where((t) => t.songId.equals(id))).go();
  }

  Future<void> deleteMissingSongs(List<String> existingFilePaths) async {
    await (delete(songsTable)..where((t) => t.filePath.isNotIn(existingFilePaths))).go();
  }

  Future<void> toggleFavorite(String songId, bool isFavorite) async {
    await (update(songsTable)..where((t) => t.id.equals(songId))).write(
      SongsTableCompanion(isFavorite: Value(isFavorite)),
    );
  }

  Future<List<Song>> getFavoriteSongs() async {
    final query = select(songsTable)
      ..where((t) => t.isFavorite.equals(true))
      ..orderBy([(t) => OrderingTerm(expression: t.title, mode: OrderingMode.asc)]);
    final rows = await query.get();
    return rows.map(_rowToSong).toList();
  }

  Future<void> recordSongPlayed(String songId) async {
    final song = await getSongById(songId);
    if (song != null) {
      await (update(songsTable)..where((t) => t.id.equals(songId))).write(
        SongsTableCompanion(
          playCount: Value(song.playCount + 1),
          lastPlayed: Value(DateTime.now()),
        ),
      );
    }
  }

  // --- Smart Collections ---

  Future<List<Song>> getRecentlyAddedSongs({int limit = 50}) async {
    final query = select(songsTable)
      ..orderBy([(t) => OrderingTerm(expression: t.dateAdded, mode: OrderingMode.desc)])
      ..limit(limit);
    final rows = await query.get();
    return rows.map(_rowToSong).toList();
  }

  Future<List<Song>> getRecentlyPlayedSongs({int limit = 50}) async {
    final query = select(songsTable)
      ..where((t) => t.lastPlayed.isNotNull())
      ..orderBy([(t) => OrderingTerm(expression: t.lastPlayed, mode: OrderingMode.desc)])
      ..limit(limit);
    final rows = await query.get();
    return rows.map(_rowToSong).toList();
  }

  Future<List<Song>> getMostPlayedSongs({int limit = 50}) async {
    final query = select(songsTable)
      ..where((t) => t.playCount.isBiggerThanValue(0))
      ..orderBy([(t) => OrderingTerm(expression: t.playCount, mode: OrderingMode.desc)])
      ..limit(limit);
    final rows = await query.get();
    return rows.map(_rowToSong).toList();
  }

  Future<List<Song>> getNeverPlayedSongs() async {
    final query = select(songsTable)
      ..where((t) => t.playCount.equals(0))
      ..orderBy([(t) => OrderingTerm(expression: t.title, mode: OrderingMode.asc)]);
    final rows = await query.get();
    return rows.map(_rowToSong).toList();
  }

  Future<List<Song>> getLongestTracks({int limit = 50}) async {
    final query = select(songsTable)
      ..orderBy([(t) => OrderingTerm(expression: t.durationMs, mode: OrderingMode.desc)])
      ..limit(limit);
    final rows = await query.get();
    return rows.map(_rowToSong).toList();
  }

  // --- Search ---

  Future<List<Song>> searchSongs(String queryText) async {
    final term = '%${queryText.toLowerCase()}%';
    final query = select(songsTable)
      ..where((t) =>
          t.title.lower().like(term) |
          t.artist.lower().like(term) |
          t.album.lower().like(term) |
          t.genre.lower().like(term) |
          t.folder.lower().like(term))
      ..orderBy([(t) => OrderingTerm(expression: t.title, mode: OrderingMode.asc)]);
    final rows = await query.get();
    return rows.map(_rowToSong).toList();
  }

  // --- Playlists ---

  Future<List<Playlist>> getAllPlaylists() async {
    final rows = await select(playlistsTable).get();
    final playlists = <Playlist>[];
    for (final r in rows) {
      final songs = await getPlaylistSongs(r.id);
      final totalMs = songs.fold<int>(0, (sum, s) => sum + s.durationMs);
      playlists.add(Playlist(
        id: r.id,
        name: r.name,
        trackCount: songs.length,
        totalDurationMs: totalMs,
        customArtworkPath: r.customArtworkPath,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
        isSmart: r.isSmart,
      ));
    }
    return playlists;
  }

  Future<void> createPlaylist(Playlist playlist) async {
    await into(playlistsTable).insertOnConflictUpdate(
      PlaylistsTableCompanion(
        id: Value(playlist.id),
        name: Value(playlist.name),
        customArtworkPath: Value(playlist.customArtworkPath),
        createdAt: Value(playlist.createdAt),
        updatedAt: Value(playlist.updatedAt),
        isSmart: Value(playlist.isSmart),
      ),
    );
  }

  Future<void> deletePlaylist(String playlistId) async {
    await (delete(playlistsTable)..where((t) => t.id.equals(playlistId))).go();
    await (delete(playlistSongsTable)..where((t) => t.playlistId.equals(playlistId))).go();
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    final existing = await (select(playlistSongsTable)
          ..where((t) => t.playlistId.equals(playlistId)))
        .get();
    final nextSortOrder = existing.isEmpty
        ? 0
        : (existing.map((e) => e.sortOrder).reduce((a, b) => a > b ? a : b) + 1);

    await into(playlistSongsTable).insertOnConflictUpdate(
      PlaylistSongsTableCompanion(
        playlistId: Value(playlistId),
        songId: Value(songId),
        sortOrder: Value(nextSortOrder),
      ),
    );
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    await (delete(playlistSongsTable)
          ..where((t) => t.playlistId.equals(playlistId) & t.songId.equals(songId)))
        .go();
  }

  Future<List<Song>> getPlaylistSongs(String playlistId) async {
    final query = select(playlistSongsTable).join([
      innerJoin(songsTable, songsTable.id.equalsExp(playlistSongsTable.songId)),
    ])
      ..where(playlistSongsTable.playlistId.equals(playlistId))
      ..orderBy([OrderingTerm(expression: playlistSongsTable.sortOrder, mode: OrderingMode.asc)]);

    final rows = await query.get();
    return rows.map((r) => _rowToSong(r.readTable(songsTable))).toList();
  }

  // --- Playback State Persistence ---

  Future<void> savePlaybackState({
    required String? currentSongId,
    required int positionMs,
    required PlaybackContext context,
    required bool isShuffleEnabled,
    required RepeatMode repeatMode,
    required String manualQueueJson,
    required String automaticPoolJson,
    required String shuffleStateJson,
  }) async {
    // We maintain a single row with id = 1
    await into(playbackStateTable).insertOnConflictUpdate(
      PlaybackStateTableCompanion(
        id: const Value(1),
        currentSongId: Value(currentSongId),
        positionMs: Value(positionMs),
        contextType: Value(context.type.name),
        contextId: Value(context.id),
        contextName: Value(context.name),
        isShuffleEnabled: Value(isShuffleEnabled),
        repeatMode: Value(repeatMode.name),
        manualQueueJson: Value(manualQueueJson),
        automaticPoolJson: Value(automaticPoolJson),
        shuffleStateJson: Value(shuffleStateJson),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<PlaybackStateTableData?> getLatestPlaybackState() async {
    return (select(playbackStateTable)..where((t) => t.id.equals(1))).getSingleOrNull();
  }

  // Helper row mapper
  Song _rowToSong(SongsTableData r) {
    return Song(
      id: r.id,
      title: r.title,
      artist: r.artist,
      album: r.album,
      albumArtist: r.albumArtist,
      genre: r.genre,
      year: r.year,
      trackNumber: r.trackNumber,
      durationMs: r.durationMs,
      fileSize: r.fileSize,
      filePath: r.filePath,
      folder: r.folder,
      dateAdded: r.dateAdded,
      dateModified: r.dateModified,
      artworkUri: r.artworkUri,
      lrcPath: r.lrcPath,
      isFavorite: r.isFavorite,
      playCount: r.playCount,
      lastPlayed: r.lastPlayed,
    );
  }
}
