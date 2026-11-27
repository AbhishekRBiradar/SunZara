import 'dart:async';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunzara/core/models/song.dart';
import 'package:sunzara/features/audio/domain/local_stream_proxy.dart';
import 'package:sunzara/features/audio/domain/sunzara_audio_handler.dart';
import 'package:sunzara/features/audio/domain/youtube_stream_service.dart';
import 'package:sunzara/features/audio/presentation/playback_controller.dart';
import 'package:sunzara/features/database/app_database.dart';
import 'package:sunzara/features/library/domain/music_repository.dart';
import 'package:sunzara/features/queue/domain/queue_manager.dart';
import 'package:sunzara/features/search/domain/voice_search_service.dart';
import 'package:sunzara/features/search/presentation/online_search_screen.dart';
import 'package:sunzara/features/search/presentation/widgets/voice_search_sheet.dart';

class _TestHandler extends SunZaraAudioHandler {
  @override
  Future<void> setSong(Song song, {bool autoPlay = true, Duration? startPosition}) async {}
  @override
  Future<void> play() async {}
  @override
  Future<void> pause() async {}
  @override
  Future<void> stop() async {}
  @override
  Future<void> seek(Duration position) async {}
  @override
  Future<void> setSpeed(double speed) async {}
  @override
  Future<void> release() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('YouTube Music Song-Only Parsing', () {
    test('Parses song items with artist, album, duration, upscaled art and filters podcast episodes', () {
      final sample = {
        'contents': [
          {
            'musicResponsiveListItemRenderer': {
              'playlistItemData': {'videoId': 'vid_song_01'},
              'flexColumns': [
                {
                  'musicResponsiveListItemFlexColumnRenderer': {
                    'text': {
                      'runs': [
                        {
                          'text': 'Sample Track One',
                          'navigationEndpoint': {
                            'watchEndpoint': {
                              'videoId': 'vid_song_01',
                              'watchEndpointMusicSupportedConfigs': {
                                'watchEndpointMusicConfig': {
                                  'musicVideoType': 'MUSIC_VIDEO_TYPE_ATV',
                                },
                              },
                            },
                          },
                        },
                      ],
                    },
                  },
                },
                {
                  'musicResponsiveListItemFlexColumnRenderer': {
                    'text': {
                      'runs': [
                        {'text': 'Singer A'},
                        {'text': ' • '},
                        {'text': 'Album One'},
                        {'text': ' • '},
                        {'text': '4:15'},
                      ],
                    },
                  },
                },
              ],
              'thumbnail': {
                'musicThumbnailRenderer': {
                  'thumbnail': {
                    'thumbnails': [
                      {'url': 'https://lh3.googleusercontent.com/art=w120-h120-l90-rj'},
                    ],
                  },
                },
              },
            },
          },
          {
            'musicResponsiveListItemRenderer': {
              'playlistItemData': {'videoId': 'vid_pod_02'},
              'flexColumns': [
                {
                  'musicResponsiveListItemFlexColumnRenderer': {
                    'text': {
                      'runs': [
                        {
                          'text': 'Non-Music Episode',
                          'navigationEndpoint': {
                            'watchEndpoint': {
                              'videoId': 'vid_pod_02',
                              'watchEndpointMusicSupportedConfigs': {
                                'watchEndpointMusicConfig': {
                                  'musicVideoType': 'MUSIC_VIDEO_TYPE_PODCAST_EPISODE',
                                },
                              },
                            },
                          },
                        },
                      ],
                    },
                  },
                },
                {
                  'musicResponsiveListItemFlexColumnRenderer': {
                    'text': {
                      'runs': [
                        {'text': 'Talk Show • 45:00'},
                      ],
                    },
                  },
                },
              ],
            },
          },
        ],
      };

      final songs = YouTubeStreamService.parseMusicSongsResponse(sample);
      expect(songs.length, 1);
      final track = songs.first;
      expect(track.id, 'yt_vid_song_01');
      expect(track.title, 'Sample Track One');
      expect(track.artist, 'Singer A');
      expect(track.album, 'Album One');
      expect(track.durationMs, 255000);
      expect(track.artworkUri, 'https://lh3.googleusercontent.com/art=w544-h544-l90-rj');
    });

    test('Parses and deduplicates YouTube Music search suggestions', () {
      final payload = {
        'contents': [
          {
            'searchSuggestionRenderer': {
              'suggestion': {
                'runs': [
                  {'text': 'night '},
                  {'text': 'drive'},
                ],
              },
            },
          },
          {
            'searchSuggestionRenderer': {
              'suggestion': {
                'runs': [
                  {'text': 'Night Drive'},
                ],
              },
            },
          },
        ],
      };

      final items = YouTubeStreamService.parseMusicSuggestionsResponse(payload);
      expect(items, ['night drive']);
    });
  });

  group('Voice Search Widget Integration', () {
    testWidgets('Tapping Voice Search button populates query and enters search state', (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      final repo = MusicRepository(db);
      final qm = QueueManager();
      final handler = _TestHandler();
      final controller = PlaybackController(
        audioHandler: handler,
        queueManager: qm,
        repository: repo,
      );

      addTearDown(() async {
        VoiceSearchService.instance.testRecognizer = null;
        controller.dispose();
        await handler.release();
        LocalStreamProxy.instance.close();
        YouTubeStreamService.instance.close();
        await db.close();
      });

      VoiceSearchService.instance.testRecognizer = ({String? prompt}) async => 'acoustic chill';

      await tester.pumpWidget(
        MaterialApp(
          home: OnlineSearchScreen(
            repository: repo,
            playbackController: controller,
          ),
        ),
      );

      final micFinder = find.byIcon(Icons.mic_rounded);
      expect(micFinder, findsOneWidget);

      await tester.tap(micFinder);
      await tester.pump();
      await tester.pumpAndSettle();

      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.controller?.text, 'acoustic chill');
    });

    testWidgets('VoiceSearchSheet displays SunZara branding, live partial transcript, and returns final text', (tester) async {
      final streamCtrl = StreamController<VoiceSessionEvent>.broadcast(sync: true);
      addTearDown(streamCtrl.close);
      String? returnedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  returnedValue = await showModalBottomSheet<String?>(
                    context: context,
                    builder: (_) => VoiceSearchSheet(
                      events: streamCtrl.stream,
                      onStartListening: () async => true,
                      onStopListening: () async {},
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      streamCtrl.add(const VoiceSessionEvent(type: 'ready'));
      streamCtrl.add(const VoiceSessionEvent(type: 'rms', rms: 6.0));
      streamCtrl.add(const VoiceSessionEvent(type: 'partial', text: 'lofi beats'));
      await tester.pump();

      expect(find.text('सुन ज़रा • Listening...'), findsOneWidget);
      expect(find.text('"lofi beats"'), findsOneWidget);

      streamCtrl.add(const VoiceSessionEvent(type: 'result', text: 'lofi beats chill'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump(const Duration(milliseconds: 350));

      expect(returnedValue, 'lofi beats chill');
    });
  });
}
