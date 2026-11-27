import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../../../core/models/song.dart';

class YouTubeStreamService {
  static final YouTubeStreamService instance = YouTubeStreamService._internal();

  YouTubeStreamService._internal() {
    initDiskCache();
  }

  factory YouTubeStreamService() => instance;

  static const Map<String, String> streamingHeaders = {
    'User-Agent': 'com.google.ios.youtube/20.10.4 (iPhone16,2; U; CPU iOS 18_3_2 like Mac OS X;)',
  };

  /// Returns matching HTTP headers for the YouTube client that issued [url]
  static Map<String, String> headersForUrl(String url) {
    final client = Uri.tryParse(url)?.queryParameters['c']?.toUpperCase();
    if (client == 'IOS') {
      return streamingHeaders;
    }
    if (client == 'ANDROID') {
      return const {
        'User-Agent': 'com.google.android.youtube/20.10.38 (Linux; U; Android 11) gzip',
      };
    }
    return const {};
  }

  final Map<String, ({List<String> urls, DateTime expiresAt})> _streamCache = {};
  final Map<String, String> _videoIdCache = {};
  bool _diskCacheLoaded = false;
  Timer? _saveDebounceTimer;

  YoutubeExplode? _ytClient;

  YoutubeExplode get _yt => _ytClient ??= YoutubeExplode();

  /// Loads persistent video ID mappings from disk to make lookups instantaneous
  Future<void> initDiskCache() async {
    if (_diskCacheLoaded) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/sunzara_yt_vids.json');
      if (await file.exists()) {
        final jsonStr = await file.readAsString();
        final data = jsonDecode(jsonStr) as Map<String, dynamic>;
        data.forEach((k, v) {
          if (v is String && v.isNotEmpty) {
            _videoIdCache[k] = v;
          }
        });
      }
      _diskCacheLoaded = true;
    } catch (_) {}
  }

  /// Debounced asynchronous persistence of video IDs to disk
  void _scheduleSaveDiskCache() {
    _saveDebounceTimer?.cancel();
    _saveDebounceTimer = Timer(const Duration(seconds: 2), () async {
      try {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/sunzara_yt_vids.json');
        await file.writeAsString(jsonEncode(_videoIdCache));
      } catch (_) {}
    });
  }

  /// Cleans and simplifies a song search query for fast matching
  String sanitizeQuery(String query) {
    var clean = query.trim();
    // Remove (feat. ...), [Official Video], (From "..."), etc.
    clean = clean.replaceAll(
      RegExp(r'\s*[\(\[][^\]\)]*?(feat|ft|from|official|video|audio|version|remaster|soundtrack|lyric)[^\]\)]*?[\)\]]', caseSensitive: false),
      ' ',
    );
    // Remove trailing " - Male Version", " - Original Version", " - Remastered", etc.
    clean = clean.replaceAll(
      RegExp(r'\s*-\s*(male|female|original|remastered|bonus|version|slowed|lofi).*$', caseSensitive: false),
      ' ',
    );
    // Replace semicolons with space and collapse whitespace
    clean = clean.replaceAll(';', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    return clean;
  }

  /// Resolves ordered candidate audio stream URLs (m4a/aac first, then opus/webm).
  /// Uses direct Innertube /player first (avoids youtube_explode's extra HEAD probe
  /// that triggers 403s on Android streams), falling back to youtube_explode only if needed.
  Future<List<String>> resolveAudioStreamCandidates(
    String source, {
    bool forceRefresh = false,
  }) async {
    final cleanSource = source.trim();
    if (cleanSource.isEmpty) return const [];

    // Check memory cache
    if (!forceRefresh && _streamCache.containsKey(cleanSource)) {
      final cached = _streamCache[cleanSource]!;
      if (DateTime.now().isBefore(cached.expiresAt) && cached.urls.isNotEmpty) {
        return cached.urls;
      } else {
        _streamCache.remove(cleanSource);
      }
    }

    try {
      String? videoId;

      if (cleanSource.startsWith('yt:video:')) {
        videoId = cleanSource.replaceFirst('yt:video:', '').trim();
      } else if (cleanSource.startsWith('yt:search:')) {
        final query = cleanSource.replaceFirst('yt:search:', '').trim();
        videoId = await _findBestVideoIdForQuery(query);
      } else if (!forceRefresh &&
          (cleanSource.startsWith('http://') || cleanSource.startsWith('https://'))) {
        return [cleanSource];
      } else {
        videoId = await _findBestVideoIdForQuery(cleanSource);
      }

      if (videoId == null || videoId.isEmpty) {
        return const [];
      }

      // 1. Direct Innertube androidSdkless /player (~250ms, no extra HEAD check)
      final directUrls = await _fetchInnertubePlayerAudioUrls(videoId);
      if (directUrls.isNotEmpty) {
        _streamCache[cleanSource] = (
          urls: directUrls,
          expiresAt: DateTime.now().add(const Duration(hours: 4)),
        );
        return directUrls;
      }

      // 2. Fallback to youtube_explode manifest (for ciphered / age-gated tracks)
      StreamManifest? manifest;
      try {
        manifest = await _yt.videos.streamsClient
            .getManifest(
              VideoId(videoId),
              ytClients: [YoutubeApiClient.androidSdkless],
              requireWatchPage: false,
            )
            .timeout(const Duration(seconds: 4));
      } catch (_) {
        try {
          manifest = await _yt.videos.streamsClient
              .getManifest(
                VideoId(videoId),
                requireWatchPage: false,
              )
              .timeout(const Duration(seconds: 4));
        } catch (_) {}
      }

      if (manifest != null && (manifest.muxed.isNotEmpty || manifest.audioOnly.isNotEmpty)) {
        // Prefer progressive muxed MP4 streams (e.g. itag 18) which stream past 1 MB without 403 cutoff.
        final muxedSorted = List<MuxedStreamInfo>.from(manifest.muxed)
          ..sort((a, b) => a.bitrate.bitsPerSecond.compareTo(b.bitrate.bitsPerSecond));
        final audioSorted = List<AudioOnlyStreamInfo>.from(manifest.audioOnly)
          ..sort((a, b) => b.bitrate.bitsPerSecond.compareTo(a.bitrate.bitsPerSecond));
        final urls = [
          ...muxedSorted.map((s) => s.url.toString()),
          ...audioSorted.map((s) => s.url.toString()),
        ];
        _streamCache[cleanSource] = (
          urls: urls,
          expiresAt: DateTime.now().add(const Duration(hours: 4)),
        );
        return urls;
      }
    } catch (e) {
      debugPrint('YouTubeStreamService error resolving "$source": $e');
    }
    return const [];
  }

  /// Resolves best single direct audio stream URL for a query or video ID
  Future<String?> resolveAudioStreamUrl(String source, {bool forceRefresh = false}) async {
    final candidates = await resolveAudioStreamCandidates(source, forceRefresh: forceRefresh);
    return candidates.isNotEmpty ? candidates.first : null;
  }

  Future<List<String>> _fetchInnertubePlayerAudioUrls(String videoId) async {
    try {
      const ua = 'com.google.android.youtube/20.10.38 (Linux; U; Android 11) gzip';
      final res = await http
          .post(
            Uri.parse('https://www.youtube.com/youtubei/v1/player?prettyPrint=false'),
            headers: const {
              'Content-Type': 'application/json',
              'User-Agent': ua,
            },
            body: jsonEncode({
              'context': {
                'client': {
                  'clientName': 'ANDROID',
                  'clientVersion': '20.10.38',
                  'userAgent': ua,
                  'hl': 'en',
                  'timeZone': 'UTC',
                  'utcOffsetMinutes': 0,
                  'osName': 'Android',
                  'osVersion': '11',
                },
              },
              'videoId': videoId,
            }),
          )
          .timeout(const Duration(seconds: 5));

      if (res.statusCode != 200) return const [];
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final streamingData = data['streamingData'] as Map<String, dynamic>?;
      if (streamingData == null) return const [];

      return selectPlayableStreamUrls(streamingData);
    } catch (e) {
      debugPrint('YouTubeStreamService Innertube /player error for $videoId: $e');
      return const [];
    }
  }

  /// Extracts and orders playable stream URLs from Innertube `streamingData`.
  /// Progressive muxed MP4 formats (such as itag 18 with AAC audio) stream the entire
  /// track without YouTube's ~1 MB (403) throttle applied to adaptive audio-only formats,
  /// so muxed MP4 formats are tried first while adaptive formats remain as fallback.
  @visibleForTesting
  static List<String> selectPlayableStreamUrls(Map<String, dynamic> streamingData) {
    final muxedFormats = (streamingData['formats'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .where((f) {
      final mime = (f['mimeType'] as String? ?? '').toLowerCase();
      final url = f['url'] as String?;
      return mime.contains('mp4') && url != null && url.isNotEmpty;
    }).toList();

    muxedFormats.sort((a, b) {
      int rank(Map<String, dynamic> f) => (f['itag'] as int? ?? 0) == 18 ? 1 : 0;
      final cmp = rank(b).compareTo(rank(a));
      if (cmp != 0) return cmp;
      // Prefer lighter bitrate among muxed streams for faster buffering & lower data use.
      final aa = (a['bitrate'] as num? ?? 0).toInt();
      final ba = (b['bitrate'] as num? ?? 0).toInt();
      return aa.compareTo(ba);
    });

    final adaptiveAudio = (streamingData['adaptiveFormats'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .where((f) {
      final mime = (f['mimeType'] as String? ?? '').toLowerCase();
      final url = f['url'] as String?;
      return mime.startsWith('audio/') && url != null && url.isNotEmpty;
    }).toList();

    adaptiveAudio.sort((a, b) {
      int rank(Map<String, dynamic> f) {
        final itag = f['itag'] as int? ?? 0;
        if (itag == 140) return 3;
        if (itag == 251) return 2;
        final mime = (f['mimeType'] as String? ?? '').toLowerCase();
        return mime.contains('mp4') ? 1 : 0;
      }

      final cmp = rank(b).compareTo(rank(a));
      if (cmp != 0) return cmp;
      final ba = (b['bitrate'] as num? ?? 0).toInt();
      final aa = (a['bitrate'] as num? ?? 0).toInt();
      return ba.compareTo(aa);
    });

    return [
      ...muxedFormats.map((f) => f['url'] as String),
      ...adaptiveAudio.map((f) => f['url'] as String),
    ];
  }

  static const String _ytmSongsParams = 'EgWKAQIIAWoKEAMQBBAJEAoQBQ==';

  static Map<String, dynamic> _ytmContext() => {
        'client': {
          'clientName': 'WEB_REMIX',
          'clientVersion': '1.20241127.01.00',
          'hl': 'en',
          'gl': 'IN',
        },
      };

  static const Map<String, String> _ytmHeaders = {
    'Content-Type': 'application/json',
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Origin': 'https://music.youtube.com',
  };

  /// Resolves video ID strictly from YouTube Music Songs search with disk cache.
  Future<String?> _findBestVideoIdForQuery(String query) async {
    await initDiskCache();
    final cleanQuery = sanitizeQuery(query);
    if (_videoIdCache.containsKey(cleanQuery)) {
      return _videoIdCache[cleanQuery];
    }

    try {
      final songs = await searchOnlineSongs(cleanQuery, limit: 1);
      if (songs.isNotEmpty) {
        final rawId = songs.first.filePath.replaceFirst('yt:video:', '').trim();
        if (rawId.isNotEmpty) {
          _videoIdCache[cleanQuery] = rawId;
          _scheduleSaveDiskCache();
          return rawId;
        }
      }
    } catch (e) {
      debugPrint('YouTubeStreamService song lookup error for "$query": $e');
    }
    return null;
  }

  /// Pre-resolves video ID ahead of time so playback tap has 0ms search delay
  Future<String?> preloadVideoId(String query) async {
    await initDiskCache();
    return _findBestVideoIdForQuery(query);
  }

  /// Pre-warms video IDs in the background for a batch of songs
  void prewarmSongs(List<Song> songs) {
    unawaited(Future(() async {
      await initDiskCache();
      for (final song in songs) {
        if (!song.isOnline) continue;
        String query = song.filePath;
        if (query.startsWith('yt:search:')) {
          query = query.replaceFirst('yt:search:', '').trim();
        } else if (query.startsWith('yt:video:')) {
          continue;
        } else {
          query = '${song.title} ${song.artist}'.trim();
        }
        final clean = sanitizeQuery(query);
        if (!_videoIdCache.containsKey(clean)) {
          await _findBestVideoIdForQuery(clean);
          await Future.delayed(const Duration(milliseconds: 120));
        }
      }
    }));
  }

  /// Preloads the audio stream for upcoming tracks in the background
  void preloadStream(String source) {
    if (source.isEmpty) return;
    final clean = source.trim();
    if (_streamCache.containsKey(clean)) return;
    unawaited(resolveAudioStreamUrl(clean));
  }

  /// Fetches song-focused autocomplete suggestions for queries of 3+ chars
  Future<List<String>> fetchSearchSuggestions(String query) async {
    final clean = query.trim();
    if (clean.length < 3) return const [];

    try {
      final res = await http
          .post(
            Uri.parse(
              'https://music.youtube.com/youtubei/v1/music/get_search_suggestions?prettyPrint=false',
            ),
            headers: _ytmHeaders,
            body: jsonEncode({
              'context': _ytmContext(),
              'input': clean,
            }),
          )
          .timeout(const Duration(seconds: 3));

      if (res.statusCode == 200) {
        final items = parseMusicSuggestionsResponse(jsonDecode(res.body));
        if (items.isNotEmpty) return items;
      }
    } catch (e) {
      debugPrint('YTM suggest error: $e');
    }

    try {
      final uri = Uri.parse(
        'https://suggestqueries.google.com/complete/search?client=firefox&ds=yt&q=${Uri.encodeQueryComponent('$clean song')}',
      );
      final res = await http.get(uri, headers: {
        'User-Agent': 'Mozilla/5.0',
      }).timeout(const Duration(seconds: 3));

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is List && decoded.length > 1 && decoded[1] is List) {
          return (decoded[1] as List)
              .whereType<String>()
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .take(8)
              .toList();
        }
      }
    } catch (_) {}
    return const [];
  }

  /// Extracts clean suggestion strings from YouTube Music suggestion payload.
  @visibleForTesting
  static List<String> parseMusicSuggestionsResponse(dynamic decoded, {int limit = 8}) {
    final results = <String>[];
    final seen = <String>{};

    void walk(dynamic node) {
      if (results.length >= limit) return;
      if (node is Map<String, dynamic>) {
        final ssr = node['searchSuggestionRenderer'];
        if (ssr is Map<String, dynamic>) {
          final runs = ssr['suggestion']?['runs'] as List? ?? const [];
          final text = runs
              .whereType<Map>()
              .map((r) => r['text'] as String? ?? '')
              .join()
              .trim();
          final key = text.toLowerCase();
          if (text.isNotEmpty && seen.add(key)) {
            results.add(text);
          }
          return;
        }
        for (final v in node.values) {
          walk(v);
          if (results.length >= limit) break;
        }
      } else if (node is List) {
        for (final item in node) {
          walk(item);
          if (results.length >= limit) break;
        }
      }
    }

    walk(decoded);
    return results;
  }

  /// Searches YouTube Music Songs filter exclusively so only music songs are returned.
  Future<List<Song>> searchOnlineSongs(String query, {int limit = 25}) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    try {
      final res = await http
          .post(
            Uri.parse('https://music.youtube.com/youtubei/v1/search?prettyPrint=false'),
            headers: _ytmHeaders,
            body: jsonEncode({
              'context': _ytmContext(),
              'query': cleanQuery,
              'params': _ytmSongsParams,
            }),
          )
          .timeout(const Duration(seconds: 6));

      if (res.statusCode == 200) {
        return parseMusicSongsResponse(jsonDecode(res.body), limit: limit);
      }
    } catch (e) {
      debugPrint('YouTube Music song search error: $e');
    }
    return [];
  }

  /// Parses `musicResponsiveListItemRenderer` rows from YouTube Music Songs search.
  @visibleForTesting
  static List<Song> parseMusicSongsResponse(dynamic decoded, {int limit = 25}) {
    final songs = <Song>[];
    final seenIds = <String>{};
    final durationRegExp = RegExp(r'^\d{1,2}:\d{2}(:\d{2})?$');
    final viewsRegExp = RegExp(r'^[\d,.]+\s*[KMB]?\s*(views|plays)$', caseSensitive: false);

    String extractRunsText(dynamic obj) {
      final runs = obj?['runs'] as List? ?? const [];
      return runs
          .whereType<Map>()
          .map((r) => r['text'] as String? ?? '')
          .join()
          .trim();
    }

    void extractSongs(dynamic node) {
      if (songs.length >= limit) return;
      if (node is Map<String, dynamic>) {
        final item = node['musicResponsiveListItemRenderer'];
        if (item is Map<String, dynamic>) {
          final watchConfig = item['flexColumns']?[0]?['musicResponsiveListItemFlexColumnRenderer']
                  ?['text']?['runs']?[0]?['navigationEndpoint']?['watchEndpoint']
              as Map<String, dynamic>?;
          final musicVideoType = watchConfig?['watchEndpointMusicSupportedConfigs']
                  ?['watchEndpointMusicConfig']?['musicVideoType'] as String? ??
              '';

          // Skip non-music podcast episodes if any appear in results.
          if (musicVideoType == 'MUSIC_VIDEO_TYPE_PODCAST_EPISODE') return;

          final vid = (item['playlistItemData']?['videoId'] as String?) ??
              (watchConfig?['videoId'] as String?);
          if (vid == null || vid.isEmpty || !seenIds.add(vid)) return;

          final flexCols = item['flexColumns'] as List? ?? const [];
          if (flexCols.isEmpty) return;

          final title = extractRunsText(
            flexCols[0]?['musicResponsiveListItemFlexColumnRenderer']?['text'],
          );
          if (title.isEmpty) return;

          String subtitle = '';
          if (flexCols.length > 1) {
            subtitle = extractRunsText(
              flexCols[1]?['musicResponsiveListItemFlexColumnRenderer']?['text'],
            );
          }

          String durationText = '';
          final fixedCols = item['fixedColumns'] as List? ?? const [];
          for (final fc in fixedCols) {
            final t = extractRunsText(
              fc?['musicResponsiveListItemFixedColumnRenderer']?['text'],
            );
            if (durationRegExp.hasMatch(t)) {
              durationText = t;
              break;
            }
          }

          final metaTokens = subtitle
              .split('•')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();

          if (durationText.isEmpty &&
              metaTokens.isNotEmpty &&
              durationRegExp.hasMatch(metaTokens.last)) {
            durationText = metaTokens.removeLast();
          }

          metaTokens.removeWhere(
            (t) => t.toLowerCase() == 'song' || viewsRegExp.hasMatch(t),
          );

          final artist = metaTokens.isNotEmpty ? metaTokens.first : 'Online Artist';
          final album = metaTokens.length > 1 ? metaTokens[1] : 'Online Music';

          final thumbs = item['thumbnail']?['musicThumbnailRenderer']?['thumbnail']
                  ?['thumbnails'] as List? ??
              const [];
          var thumbUrl = thumbs.isNotEmpty && thumbs.last is Map
              ? (thumbs.last['url'] as String? ?? '')
              : 'https://i.ytimg.com/vi/$vid/hqdefault.jpg';
          if (thumbUrl.contains('=w') && thumbUrl.contains('-h')) {
            thumbUrl = thumbUrl.replaceFirst(RegExp(r'=w\d+-h\d+'), '=w544-h544');
          }

          songs.add(Song(
            id: 'yt_$vid',
            title: title,
            artist: artist,
            album: album,
            durationMs: durationText.isNotEmpty ? _parseDurationStaticMs(durationText) : 210000,
            fileSize: 0,
            filePath: 'yt:video:$vid',
            folder: 'Online Stream',
            artworkUri: thumbUrl.isNotEmpty ? thumbUrl : null,
            dateAdded: DateTime.now(),
          ));
          return;
        }
        for (final v in node.values) {
          extractSongs(v);
          if (songs.length >= limit) break;
        }
      } else if (node is List) {
        for (final item in node) {
          extractSongs(item);
          if (songs.length >= limit) break;
        }
      }
    }

    extractSongs(decoded);
    return songs;
  }

  static int _parseDurationStaticMs(String text) {
    final parts = text.split(':').map((p) => int.tryParse(p.trim()) ?? 0).toList();
    if (parts.length == 2) {
      return ((parts[0] * 60) + parts[1]) * 1000;
    }
    if (parts.length == 3) {
      return ((parts[0] * 3600) + (parts[1] * 60) + parts[2]) * 1000;
    }
    return 210000;
  }

  void close() {
    _saveDebounceTimer?.cancel();
    _ytClient?.close();
    _ytClient = null;
    _streamCache.clear();
    _videoIdCache.clear();
  }
}
