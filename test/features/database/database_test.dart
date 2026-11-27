import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunzara/core/models/playback_context.dart';
import 'package:sunzara/core/models/song.dart';
import 'package:sunzara/features/database/app_database.dart';
import 'package:sunzara/features/library/domain/music_repository.dart';

Song createTestSong({
  required String id,
  required String title,
  required String artist,
  required String album,
  String? genre,
  int durationMs = 180000,
  int playCount = 0,
  DateTime? dateAdded,
  DateTime? lastPlayed,
  bool isFavorite = false,
}) {
  return Song(
    id: id,
    title: title,
    artist: artist,
    album: album,
    genre: genre,
    durationMs: durationMs,
    fileSize: 4000000,
    filePath: '/storage/music/$id.mp3',
    folder: 'Music',
    dateAdded: dateAdded ?? DateTime.now(),
    lastPlayed: lastPlayed,
    isFavorite: isFavorite,
    playCount: playCount,
  );
}

void main() {
  late AppDatabase db;
  late MusicRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = MusicRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Database and MusicRepository Tests', () {
    test('Batch insert and retrieve all songs', () async {
      final s1 = createTestSong(id: '1', title: 'O Sanam', artist: 'Lucky Ali', album: 'Sunoh');
      final s2 = createTestSong(id: '2', title: 'Dekha Hai Aise Bhi', artist: 'Lucky Ali', album: 'Sifar');

      await repo.insertSongsBatch([s1, s2]);
      final all = await repo.getAllSongs();

      expect(all.length, 2);
      expect(all.map((s) => s.id), containsAll(['1', '2']));
    });

    test('Favorites toggling and query', () async {
      final s1 = createTestSong(id: '1', title: 'Song 1', artist: 'Artist A', album: 'Album A');
      final s2 = createTestSong(id: '2', title: 'Song 2', artist: 'Artist B', album: 'Album B');

      await repo.insertSongsBatch([s1, s2]);
      await repo.toggleFavorite('1', true);

      final favs = await repo.getFavoriteSongs();
      expect(favs.length, 1);
      expect(favs.first.id, '1');

      await repo.toggleFavorite('1', false);
      final emptyFavs = await repo.getFavoriteSongs();
      expect(emptyFavs.isEmpty, isTrue);
    });

    test('Record song played increments playCount and updates lastPlayed', () async {
      final s = createTestSong(id: '1', title: 'Track', artist: 'Artist', album: 'Album', playCount: 0);
      await repo.insertOrUpdateSong(s);

      await repo.recordSongPlayed('1');
      final updated = await repo.getSongById('1');

      expect(updated?.playCount, 1);
      expect(updated?.lastPlayed, isNotNull);
    });

    test('Smart collections: Recently Played, Most Played, Never Played', () async {
      final s1 = createTestSong(id: '1', title: 'Track 1', artist: 'A', album: 'A', playCount: 5, lastPlayed: DateTime(2026, 1, 10));
      final s2 = createTestSong(id: '2', title: 'Track 2', artist: 'B', album: 'B', playCount: 20, lastPlayed: DateTime(2026, 1, 15));
      final s3 = createTestSong(id: '3', title: 'Track 3', artist: 'C', album: 'C', playCount: 0);

      await repo.insertSongsBatch([s1, s2, s3]);

      final mostPlayed = await repo.getMostPlayed();
      expect(mostPlayed.first.id, '2'); // 20 plays

      final recentlyPlayed = await repo.getRecentlyPlayed();
      expect(recentlyPlayed.first.id, '2'); // Jan 15

      final neverPlayed = await repo.getNeverPlayed();
      expect(neverPlayed.length, 1);
      expect(neverPlayed.first.id, '3');
    });

    test('Search songs across title, artist, album, and genre', () async {
      final s1 = createTestSong(id: '1', title: 'Sun Zara', artist: 'Lucky Ali', album: 'Aks', genre: 'Pop');
      final s2 = createTestSong(id: '2', title: 'Tum Ho', artist: 'Mohit Chauhan', album: 'Rockstar', genre: 'Soundtrack');

      await repo.insertSongsBatch([s1, s2]);

      final r1 = await repo.searchSongs('lucky');
      expect(r1.length, 1);
      expect(r1.first.id, '1');

      final r2 = await repo.searchSongs('Rockstar');
      expect(r2.length, 1);
      expect(r2.first.id, '2');
    });

    test('Playlists management and song associations', () async {
      final s1 = createTestSong(id: '1', title: 'Song 1', artist: 'A', album: 'A');
      final s2 = createTestSong(id: '2', title: 'Song 2', artist: 'B', album: 'B');
      await repo.insertSongsBatch([s1, s2]);

      await repo.createPlaylist('Late Night Vibes');
      final playlists = await repo.getAllPlaylists();
      expect(playlists.length, 1);
      expect(playlists.first.name, 'Late Night Vibes');

      final plId = playlists.first.id;
      await repo.addSongToPlaylist(plId, '1');
      await repo.addSongToPlaylist(plId, '2');

      final plSongs = await repo.getPlaylistSongs(plId);
      expect(plSongs.length, 2);
      expect(plSongs[0].id, '1');
      expect(plSongs[1].id, '2');

      await repo.removeSongFromPlaylist(plId, '1');
      final updatedPlSongs = await repo.getPlaylistSongs(plId);
      expect(updatedPlSongs.length, 1);
      expect(updatedPlSongs[0].id, '2');
    });

    test('Liking a song auto-creates and syncs "Liked Songs" playlist', () async {
      final onlineSong = Song(
        id: 'yt_abc',
        title: 'Online Track',
        artist: 'Artist',
        album: 'YouTube',
        durationMs: 210000,
        fileSize: 0,
        filePath: 'yt:video:abc',
        folder: 'Online Stream',
      );

      await repo.setSongFavorite(onlineSong, true);
      // Calling again should not duplicate entry
      await repo.toggleFavorite(onlineSong.id, true);

      final playlists = await repo.getAllPlaylists();
      final likedPl = playlists.where((p) => p.name == AppDatabase.likedSongsPlaylistName).toList();
      expect(likedPl.length, 1);

      final plSongs = await repo.getPlaylistSongs(likedPl.first.id);
      expect(plSongs.length, 1);
      expect(plSongs.first.id, 'yt_abc');
      expect(plSongs.first.isFavorite, isTrue);

      await repo.toggleFavorite(onlineSong.id, false);
      final afterUnlike = await repo.getPlaylistSongs(likedPl.first.id);
      expect(afterUnlike, isEmpty);
    });

    test('Playback state persistence and retrieval', () async {
      await repo.savePlaybackState(
        currentSongId: '10',
        positionMs: 45000,
        context: PlaybackContext.favorites,
        isShuffleEnabled: true,
        repeatMode: RepeatMode.all,
        manualQueueJson: '[]',
        automaticPoolJson: '[]',
        shuffleStateJson: '{"test": true}',
      );

      final state = await repo.getLatestPlaybackState();
      expect(state, isNotNull);
      expect(state?.currentSongId, '10');
      expect(state?.positionMs, 45000);
      expect(state?.contextType, 'favorites');
      expect(state?.isShuffleEnabled, isTrue);
      expect(state?.repeatMode, 'all');
    });
  });
}
