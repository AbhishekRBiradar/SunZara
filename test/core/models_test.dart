import 'package:flutter_test/flutter_test.dart';
import 'package:sunzara/core/models/song.dart';
import 'package:sunzara/core/models/playback_context.dart';
import 'package:sunzara/core/models/queue_item.dart';

void main() {
  group('Core Models Test', () {
    test('Song formattedDuration formats minutes and seconds correctly', () {
      const song = Song(
        id: '1',
        title: 'Sun Zara',
        artist: 'Lucky Ali',
        album: 'Aks',
        durationMs: 245000, // 4m 05s
        fileSize: 5000000,
        filePath: '/storage/emulated/0/Music/sun_zara.mp3',
        folder: 'Music',
      );

      expect(song.formattedDuration, '4:05');
    });

    test('Song serialization roundtrip preserves all attributes', () {
      final now = DateTime.now();
      final song = Song(
        id: 'song_99',
        title: 'Title',
        artist: 'Artist',
        album: 'Album',
        durationMs: 180000,
        fileSize: 4000000,
        filePath: '/path/to/song.mp3',
        folder: 'Music',
        dateAdded: now,
        isFavorite: true,
        playCount: 12,
      );

      final map = song.toMap();
      final deserialized = Song.fromMap(map);

      expect(deserialized.id, song.id);
      expect(deserialized.title, song.title);
      expect(deserialized.isFavorite, true);
      expect(deserialized.playCount, 12);
    });

    test('QueueItem distinguishes manual vs automatic queue types', () {
      const song = Song(
        id: '1',
        title: 'Track A',
        artist: 'Artist A',
        album: 'Album A',
        durationMs: 120000,
        fileSize: 3000000,
        filePath: '/path/a.mp3',
        folder: 'Music',
      );

      const manualItem = QueueItem(
        queueId: 'q_1',
        song: song,
        type: QueueItemType.manual,
      );

      const autoItem = QueueItem(
        queueId: 'q_2',
        song: song,
        type: QueueItemType.automatic,
      );

      expect(manualItem.isManual, isTrue);
      expect(manualItem.isAutomatic, isFalse);
      expect(autoItem.isManual, isFalse);
      expect(autoItem.isAutomatic, isTrue);
      // Different queue IDs despite identical song
      expect(manualItem == autoItem, isFalse);
    });

    test('PlaybackContext equality and serialization', () {
      const ctx = PlaybackContext(
        type: PlaybackContextType.album,
        id: 'album_10',
        name: 'Aks',
      );

      final map = ctx.toMap();
      final restored = PlaybackContext.fromMap(map);

      expect(restored.type, PlaybackContextType.album);
      expect(restored.id, 'album_10');
      expect(restored.name, 'Aks');
      expect(restored == ctx, isTrue);
    });
  });
}
