import 'dart:async';
import 'package:sunzara/core/models/album.dart';
import 'package:sunzara/core/models/artist.dart';
import 'package:sunzara/core/models/playback_context.dart';
import 'package:sunzara/core/models/playlist.dart';
import 'package:sunzara/core/models/song.dart';
import 'package:sunzara/features/database/app_database.dart';

class MusicRepository {
  final AppDatabase _db;
  final StreamController<void> _changesController = StreamController<void>.broadcast();

  MusicRepository(this._db);

  AppDatabase get database => _db;
  Stream<void> get changes => _changesController.stream;

  void _notifyChanges() {
    if (!_changesController.isClosed) {
      _changesController.add(null);
    }
  }

  // Songs
  Future<List<Song>> getAllSongs() => _db.getAllSongs();
  Stream<List<Song>> watchAllSongs() => _db.watchAllSongs();
  Future<Song?> getSongById(String id) => _db.getSongById(id);
  Future<void> insertOrUpdateSong(Song song) async {
    await _db.insertOrUpdateSong(song);
    _notifyChanges();
  }

  Future<void> insertSongsBatch(List<Song> songs) async {
    await _db.insertSongsBatch(songs);
    _notifyChanges();
  }

  Future<void> deleteSong(String id) async {
    await _db.deleteSong(id);
    _notifyChanges();
  }

  Future<void> clearSpotifyData() async {
    await _db.clearSpotifyData();
    _notifyChanges();
  }

  Future<void> deleteMissingSongs(List<String> existingPaths) async {
    await _db.deleteMissingSongs(existingPaths);
    _notifyChanges();
  }

  Future<void> toggleFavorite(String songId, bool isFavorite) async {
    await _db.toggleFavorite(songId, isFavorite);
    _notifyChanges();
  }

  /// Ensures [song] exists in local storage, sets its favorite flag,
  /// and keeps the "Liked Songs" playlist synchronized.
  Future<void> setSongFavorite(Song song, bool isFavorite) async {
    final existing = await _db.getSongById(song.id);
    if (existing == null) {
      await _db.insertOrUpdateSong(song.copyWith(isFavorite: isFavorite));
    }
    await _db.toggleFavorite(song.id, isFavorite);
    _notifyChanges();
  }

  Future<List<Song>> getFavoriteSongs() => _db.getFavoriteSongs();
  Future<void> recordSongPlayed(String songId) async {
    await _db.recordSongPlayed(songId);
    _notifyChanges();
  }

  // Smart Collections
  Future<List<Song>> getRecentlyAdded({int limit = 50}) => _db.getRecentlyAddedSongs(limit: limit);
  Future<List<Song>> getRecentlyPlayed({int limit = 50}) => _db.getRecentlyPlayedSongs(limit: limit);
  Future<List<Song>> getMostPlayed({int limit = 50}) => _db.getMostPlayedSongs(limit: limit);
  Future<List<Song>> getNeverPlayed() => _db.getNeverPlayedSongs();
  Future<List<Song>> getLongestTracks({int limit = 50}) => _db.getLongestTracks(limit: limit);

  // Search
  Future<List<Song>> searchSongs(String query) => _db.searchSongs(query);

  // Groupings: Albums, Artists, Folders, Genres
  Future<List<Album>> getAlbums() async {
    final songs = await _db.getAllSongs();
    final Map<String, List<Song>> albumGroups = {};
    for (final s in songs) {
      albumGroups.putIfAbsent(s.album, () => []).add(s);
    }

    final albums = albumGroups.entries.map((e) {
      final albumSongs = e.value;
      final totalMs = albumSongs.fold<int>(0, (sum, s) => sum + s.durationMs);
      final first = albumSongs.first;
      return Album(
        id: 'album_${e.key}',
        title: e.key,
        artist: first.albumArtist ?? first.artist,
        trackCount: albumSongs.length,
        totalDurationMs: totalMs,
        year: first.year,
        artworkUri: first.artworkUri,
      );
    }).toList();

    albums.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return albums;
  }

  Future<List<Artist>> getArtists() async {
    final songs = await _db.getAllSongs();
    final Map<String, List<Song>> artistGroups = {};
    for (final s in songs) {
      artistGroups.putIfAbsent(s.artist, () => []).add(s);
    }

    final artists = artistGroups.entries.map((e) {
      final artistSongs = e.value;
      final uniqueAlbums = artistSongs.map((s) => s.album).toSet().length;
      return Artist(
        id: 'artist_${e.key}',
        name: e.key,
        trackCount: artistSongs.length,
        albumCount: uniqueAlbums,
      );
    }).toList();

    artists.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return artists;
  }

  Future<List<String>> getFolders() async {
    final songs = await _db.getAllSongs();
    final folders = songs.map((s) => s.folder).toSet().toList()..sort();
    return folders;
  }

  Future<List<String>> getGenres() async {
    final songs = await _db.getAllSongs();
    final genres = songs
        .map((s) => s.genre?.trim())
        .where((g) => g != null && g.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList()
      ..sort();
    return genres;
  }

  Future<List<Song>> getSongsByAlbum(String albumName) async {
    final songs = await _db.getAllSongs();
    return songs.where((s) => s.album == albumName).toList()
      ..sort((a, b) => (a.trackNumber ?? 0).compareTo(b.trackNumber ?? 0));
  }

  Future<List<Song>> getSongsByArtist(String artistName) async {
    final songs = await _db.getAllSongs();
    return songs.where((s) => s.artist == artistName).toList()
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
  }

  Future<List<Song>> getSongsByFolder(String folderName) async {
    final songs = await _db.getAllSongs();
    return songs.where((s) => s.folder == folderName).toList()
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
  }

  Future<List<Song>> getSongsByGenre(String genreName) async {
    final songs = await _db.getAllSongs();
    return songs.where((s) => s.genre == genreName).toList()
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
  }

  // Playlists
  Future<List<Playlist>> getAllPlaylists() => _db.getAllPlaylists();
  Future<void> createPlaylist(String name) async {
    final playlist = Playlist(
      id: 'pl_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      createdAt: DateTime.now(),
    );
    await _db.createPlaylist(playlist);
    _notifyChanges();
  }

  Future<void> deletePlaylist(String playlistId) async {
    await _db.deletePlaylist(playlistId);
    _notifyChanges();
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    await _db.addSongToPlaylist(playlistId, songId);
    _notifyChanges();
  }

  Future<void> addSongsToPlaylistBatch(String playlistId, List<String> songIds) async {
    await _db.addSongsToPlaylistBatch(playlistId, songIds);
    _notifyChanges();
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    await _db.removeSongFromPlaylist(playlistId, songId);
    _notifyChanges();
  }

  Future<List<Song>> getPlaylistSongs(String playlistId) =>
      _db.getPlaylistSongs(playlistId);

  // Playback Persistence
  Future<void> savePlaybackState({
    required String? currentSongId,
    required int positionMs,
    required PlaybackContext context,
    required bool isShuffleEnabled,
    required RepeatMode repeatMode,
    required String manualQueueJson,
    required String automaticPoolJson,
    required String shuffleStateJson,
  }) =>
      _db.savePlaybackState(
        currentSongId: currentSongId,
        positionMs: positionMs,
        context: context,
        isShuffleEnabled: isShuffleEnabled,
        repeatMode: repeatMode,
        manualQueueJson: manualQueueJson,
        automaticPoolJson: automaticPoolJson,
        shuffleStateJson: shuffleStateJson,
      );

  Future<PlaybackStateTableData?> getLatestPlaybackState() =>
      _db.getLatestPlaybackState();
}
