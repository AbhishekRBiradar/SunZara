import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'youtube_stream_service.dart';

class LocalStreamProxy {
  static final LocalStreamProxy instance = LocalStreamProxy._internal();

  /// Size of each bounded upstream Range chunk (512 KB).
  /// YouTube's CDN rejects unbounded requests (no Range or bytes=0-) with 403,
  /// while bounded chunks return 206 Partial Content unthrottled.
  static const int chunkSizeBytes = 512 * 1024;

  LocalStreamProxy._internal();

  factory LocalStreamProxy() => instance;

  HttpServer? _server;
  Future<void>? _startFuture;
  HttpClient _client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 10)
    ..idleTimeout = const Duration(seconds: 30);

  final Map<String, String> _urlMap = {};
  int _nextId = 0;

  int get port => _server?.port ?? 0;
  bool get isRunning => _server != null;

  /// Starts the local HTTP streaming proxy on loopback IPv4
  Future<void> ensureStarted() {
    if (_server != null) return Future.value();
    return _startFuture ??= _doStart();
  }

  Future<void> _doStart() async {
    try {
      // Recreate client if previously closed (e.g. across tests)
      _client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 10)
        ..idleTimeout = const Duration(seconds: 30);
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      debugPrint('LocalStreamProxy started on http://127.0.0.1:${_server!.port}');

      _server!.listen(_handleRequest, onError: (e) {
        debugPrint('LocalStreamProxy server error: $e');
      });
    } catch (e) {
      _startFuture = null;
      debugPrint('LocalStreamProxy failed to bind: $e');
    }
  }

  /// Registers a remote audio URL and returns a clean, compact localhost proxy URL
  String registerUrl(String remoteUrl) {
    if (_server == null || _server!.port == 0) return remoteUrl;
    _nextId++;
    final id = '${DateTime.now().microsecondsSinceEpoch}_$_nextId';
    _urlMap[id] = remoteUrl;

    // Keep map bounded to last 50 tracks to prevent memory leak
    if (_urlMap.length > 50) {
      final oldestKey = _urlMap.keys.first;
      _urlMap.remove(oldestKey);
    }

    return 'http://127.0.0.1:${_server!.port}/stream?id=$id';
  }

  ({int start, int? end, bool hasRange}) _parseIncomingRange(String? header) {
    if (header == null || header.isEmpty) {
      return (start: 0, end: null, hasRange: false);
    }
    final m = RegExp(r'bytes=(\d+)-(\d*)', caseSensitive: false).firstMatch(header);
    if (m == null) {
      return (start: 0, end: null, hasRange: false);
    }
    final start = int.tryParse(m.group(1) ?? '') ?? 0;
    final endGroup = m.group(2) ?? '';
    final end = endGroup.isEmpty ? null : int.tryParse(endGroup);
    return (start: start, end: end, hasRange: true);
  }

  int? _parseTotalLength(HttpClientResponse resp, Uri upstreamUri) {
    final contentRange = resp.headers.value(HttpHeaders.contentRangeHeader);
    if (contentRange != null) {
      final m = RegExp(r'bytes\s+\d+-\d+/(\d+)', caseSensitive: false).firstMatch(contentRange);
      if (m != null) {
        final total = int.tryParse(m.group(1) ?? '');
        if (total != null && total > 0) return total;
      }
    }
    final clenParam = int.tryParse(upstreamUri.queryParameters['clen'] ?? '');
    if (clenParam != null && clenParam > 0) return clenParam;
    if (resp.contentLength > 0) return resp.contentLength;
    return null;
  }

  Future<HttpClientResponse> _fetchBoundedChunk(
    Uri upstreamUri,
    int start,
    int end,
    Map<String, String> matchedHeaders,
  ) async {
    final req = await _client.getUrl(upstreamUri).timeout(const Duration(seconds: 10));
    req.headers.set(HttpHeaders.rangeHeader, 'bytes=$start-$end');
    matchedHeaders.forEach((k, v) {
      req.headers.set(k, v);
    });
    return req.close().timeout(const Duration(seconds: 10));
  }

  Future<HttpClientResponse> _openBoundedChunkWithRetry(
    Uri upstreamUri,
    int start,
    int end,
    Map<String, String> matchedHeaders,
  ) async {
    Object? lastErr;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final resp = await _fetchBoundedChunk(upstreamUri, start, end, matchedHeaders);
        if (resp.statusCode < 500 || attempt == 2) {
          return resp;
        }
        await resp.drain<void>().catchError((_) {});
      } catch (e) {
        lastErr = e;
        if (attempt == 2) rethrow;
      }
      await Future<void>.delayed(Duration(milliseconds: 150 * (attempt + 1)));
    }
    throw lastErr ?? HttpException('Upstream chunk failed ($start-$end)');
  }

  /// Buffers a bounded chunk [start..end] into memory with retry on transient drops
  /// so mobile data stalls or truncated chunks never freeze playback mid-stream.
  Future<List<int>?> _fetchChunkBytesWithRetry(
    Uri upstreamUri,
    int start,
    int end,
    Map<String, String> matchedHeaders,
  ) async {
    final result = BytesBuilder(copy: false);
    var cursor = start;

    for (var attempt = 0; attempt < 3 && cursor <= end; attempt++) {
      HttpClientResponse? resp;
      try {
        resp = await _openBoundedChunkWithRetry(upstreamUri, cursor, end, matchedHeaders);
        if (resp.statusCode >= 400) {
          await resp.drain<void>().catchError((_) {});
          return result.isEmpty ? null : result.takeBytes();
        }
        await for (final part in resp.timeout(const Duration(seconds: 12))) {
          if (part.isEmpty) continue;
          result.add(part);
          cursor += part.length;
        }
        if (cursor > end) break;
      } catch (e) {
        debugPrint('LocalStreamProxy chunk retry ($cursor-$end, attempt $attempt): $e');
        if (attempt == 2 && result.isEmpty) rethrow;
      }
      if (cursor <= end && attempt < 2) {
        await Future<void>.delayed(Duration(milliseconds: 150 * (attempt + 1)));
      }
    }

    return result.isEmpty ? null : result.takeBytes();
  }

  Future<void> _handleRequest(HttpRequest request) async {
    var headersSent = false;
    var clientDisconnected = false;
    unawaited(
      request.response.done.then((_) {
        clientDisconnected = true;
      }, onError: (_) {
        clientDisconnected = true;
      }),
    );

    try {
      if (request.uri.path != '/stream') {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
        return;
      }

      final id = request.uri.queryParameters['id'];
      final targetUrl = id != null ? _urlMap[id] : null;

      if (targetUrl == null || targetUrl.isEmpty) {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
        return;
      }

      final upstreamUri = Uri.parse(targetUrl);
      final matchedHeaders = YouTubeStreamService.headersForUrl(targetUrl);
      final reqRange = _parseIncomingRange(request.headers.value(HttpHeaders.rangeHeader));

      final knownClen = int.tryParse(upstreamUri.queryParameters['clen'] ?? '');
      var firstEnd = reqRange.end ?? (reqRange.start + chunkSizeBytes - 1);
      firstEnd = math.min(firstEnd, reqRange.start + chunkSizeBytes - 1);
      if (knownClen != null && knownClen > 0 && firstEnd >= knownClen) {
        firstEnd = knownClen - 1;
      }
      if (firstEnd < reqRange.start) {
        firstEnd = reqRange.start;
      }

      final firstResp = await _openBoundedChunkWithRetry(
        upstreamUri,
        reqRange.start,
        firstEnd,
        matchedHeaders,
      );

      if (firstResp.statusCode >= 400) {
        debugPrint('LocalStreamProxy: upstream HTTP ${firstResp.statusCode} for range ${reqRange.start}-$firstEnd');
        request.response.statusCode = firstResp.statusCode;
        await firstResp.drain<void>().catchError((_) {});
        await request.response.close();
        return;
      }

      final totalLength = _parseTotalLength(firstResp, upstreamUri);
      final targetEnd = totalLength != null
          ? math.min(reqRange.end ?? (totalLength - 1), totalLength - 1)
          : (reqRange.end ?? firstEnd);
      final effectiveFirstEnd = math.min(firstEnd, targetEnd);

      request.response.bufferOutput = false;
      request.response.headers.set(HttpHeaders.acceptRangesHeader, 'bytes');
      final contentType = firstResp.headers.value(HttpHeaders.contentTypeHeader);
      if (contentType != null && contentType.isNotEmpty) {
        request.response.headers.set(HttpHeaders.contentTypeHeader, contentType);
      }

      if (reqRange.hasRange && totalLength != null) {
        request.response.statusCode = HttpStatus.partialContent;
        request.response.headers.set(
          HttpHeaders.contentRangeHeader,
          'bytes ${reqRange.start}-$targetEnd/$totalLength',
        );
        request.response.headers.set(
          HttpHeaders.contentLengthHeader,
          '${targetEnd - reqRange.start + 1}',
        );
      } else {
        request.response.statusCode = HttpStatus.ok;
        if (totalLength != null) {
          request.response.headers.set(HttpHeaders.contentLengthHeader, '$totalLength');
        }
      }
      headersSent = true;

      // Kick off lookahead prefetch for chunk #1 concurrently while streaming chunk #0
      var nextPrefetchStart = effectiveFirstEnd + 1;
      Future<List<int>?>? prefetchFuture;
      if (totalLength != null && nextPrefetchStart <= targetEnd) {
        final nextPrefetchEnd = math.min(nextPrefetchStart + chunkSizeBytes - 1, targetEnd);
        prefetchFuture = _fetchChunkBytesWithRetry(
          upstreamUri,
          nextPrefetchStart,
          nextPrefetchEnd,
          matchedHeaders,
        ).catchError((_) => null);
        nextPrefetchStart = nextPrefetchEnd + 1;
      }

      var cursor = reqRange.start;
      try {
        await request.response.addStream(
          firstResp.timeout(const Duration(seconds: 12)).map((chunk) {
            cursor += chunk.length;
            return chunk;
          }),
        );
      } catch (e) {
        if (clientDisconnected) rethrow;
        debugPrint('LocalStreamProxy chunk 0 interrupted at $cursor: $e');
      }

      // Finish remainder of chunk #0 cleanly if the first HTTP response truncated early
      if (!clientDisconnected && totalLength != null && cursor <= effectiveFirstEnd) {
        final tail = await _fetchChunkBytesWithRetry(
          upstreamUri,
          cursor,
          effectiveFirstEnd,
          matchedHeaders,
        );
        if (tail != null && tail.isNotEmpty && !clientDisconnected) {
          request.response.add(tail);
          await request.response.flush();
          cursor += tail.length;
        }
      }

      while (!clientDisconnected &&
          totalLength != null &&
          cursor <= targetEnd &&
          (reqRange.end == null || cursor <= reqRange.end!)) {
        if (prefetchFuture != null) {
          final currentFuture = prefetchFuture;
          // Start prefetching N+1 before awaiting N completes so transitions have zero gap
          if (nextPrefetchStart <= targetEnd) {
            final upcomingEnd = math.min(nextPrefetchStart + chunkSizeBytes - 1, targetEnd);
            prefetchFuture = _fetchChunkBytesWithRetry(
              upstreamUri,
              nextPrefetchStart,
              upcomingEnd,
              matchedHeaders,
            ).catchError((_) => null);
            nextPrefetchStart = upcomingEnd + 1;
          } else {
            prefetchFuture = null;
          }

          final bytes = await currentFuture;
          if (bytes == null || bytes.isEmpty || clientDisconnected) break;
          request.response.add(bytes);
          await request.response.flush();
          cursor += bytes.length;
        } else {
          final nextEnd = math.min(cursor + chunkSizeBytes - 1, targetEnd);
          if (nextEnd < cursor) break;
          final bytes = await _fetchChunkBytesWithRetry(
            upstreamUri,
            cursor,
            nextEnd,
            matchedHeaders,
          );
          if (bytes == null || bytes.isEmpty || clientDisconnected) break;
          request.response.add(bytes);
          await request.response.flush();
          cursor += bytes.length;
        }
      }

      await request.response.close().catchError((_) {});
    } catch (e) {
      // Client disconnected mid-stream (seek/skip) or upstream closed
      if (!headersSent) {
        try {
          request.response.statusCode = HttpStatus.internalServerError;
          await request.response.close();
        } catch (_) {}
      } else {
        try {
          await request.response.close();
        } catch (_) {}
      }
    }
  }

  void close() {
    _server?.close(force: true);
    _server = null;
    _startFuture = null;
    _urlMap.clear();
    _client.close(force: true);
  }
}
