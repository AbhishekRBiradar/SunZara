import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunzara/features/audio/domain/local_stream_proxy.dart';
import 'package:sunzara/features/audio/domain/youtube_stream_service.dart';

void main() {
  group('LocalStreamProxy Bounded Range Streaming Tests', () {
    late HttpServer mockUpstream;
    late List<int> payload;

    setUp(() async {
      // 1.3 MB payload spanning multiple 512 KB chunks
      payload = List<int>.generate(1300 * 1024, (i) => i % 251);
      mockUpstream = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      mockUpstream.listen((req) async {
        final range = req.headers.value(HttpHeaders.rangeHeader);
        // Simulate YouTube CDN rejecting requests with missing or open-ended Range
        if (range == null || !range.startsWith('bytes=')) {
          req.response.statusCode = HttpStatus.forbidden;
          await req.response.close();
          return;
        }
        final m = RegExp(r'bytes=(\d+)-(\d+)$').firstMatch(range);
        if (m == null) {
          req.response.statusCode = HttpStatus.forbidden;
          await req.response.close();
          return;
        }
        final start = int.parse(m.group(1)!);
        final end = int.parse(m.group(2)!);
        if (end - start + 1 > LocalStreamProxy.chunkSizeBytes) {
          req.response.statusCode = HttpStatus.forbidden;
          await req.response.close();
          return;
        }
        final actualEnd = end >= payload.length ? payload.length - 1 : end;
        final slice = payload.sublist(start, actualEnd + 1);
        req.response.statusCode = HttpStatus.partialContent;
        req.response.headers.set(HttpHeaders.contentTypeHeader, 'audio/mp4');
        req.response.headers.set(HttpHeaders.acceptRangesHeader, 'bytes');
        req.response.headers.set(
          HttpHeaders.contentRangeHeader,
          'bytes $start-$actualEnd/${payload.length}',
        );
        req.response.headers.set(HttpHeaders.contentLengthHeader, '${slice.length}');
        req.response.add(slice);
        await req.response.close();
      });

      await LocalStreamProxy.instance.ensureStarted();
    });

    tearDown(() async {
      LocalStreamProxy.instance.close();
      await mockUpstream.close(force: true);
    });

    test('Serves full payload as 200 OK across bounded chunks when client sends no Range', () async {
      final upstreamUrl = 'http://127.0.0.1:${mockUpstream.port}/videoplayback?clen=${payload.length}&c=ANDROID';
      final proxyUrl = LocalStreamProxy.instance.registerUrl(upstreamUrl);

      final client = HttpClient();
      final req = await client.getUrl(Uri.parse(proxyUrl));
      final resp = await req.close();

      expect(resp.statusCode, HttpStatus.ok);
      expect(resp.headers.value(HttpHeaders.acceptRangesHeader), 'bytes');
      expect(resp.headers.value(HttpHeaders.contentLengthHeader), '${payload.length}');
      final bytes = await resp.fold<List<int>>([], (acc, chunk) => acc..addAll(chunk));
      expect(bytes, payload);
      client.close(force: true);
    });

    test('Serves open-ended Range as 206 Partial Content seamlessly across chunks', () async {
      final upstreamUrl = 'http://127.0.0.1:${mockUpstream.port}/videoplayback?c=ANDROID';
      final proxyUrl = LocalStreamProxy.instance.registerUrl(upstreamUrl);

      const offset = 600 * 1024;
      final client = HttpClient();
      final req = await client.getUrl(Uri.parse(proxyUrl));
      req.headers.set(HttpHeaders.rangeHeader, 'bytes=$offset-');
      final resp = await req.close();

      expect(resp.statusCode, HttpStatus.partialContent);
      expect(
        resp.headers.value(HttpHeaders.contentRangeHeader),
        'bytes $offset-${payload.length - 1}/${payload.length}',
      );
      final bytes = await resp.fold<List<int>>([], (acc, chunk) => acc..addAll(chunk));
      expect(bytes, payload.sublist(offset));
      client.close(force: true);
    });

    test('Concurrent ensureStarted calls bind only a single loopback server', () async {
      LocalStreamProxy.instance.close();
      await Future.wait([
        LocalStreamProxy.instance.ensureStarted(),
        LocalStreamProxy.instance.ensureStarted(),
        LocalStreamProxy.instance.ensureStarted(),
      ]);
      final portAfterConcurrent = LocalStreamProxy.instance.port;
      expect(portAfterConcurrent, greaterThan(0));
      await LocalStreamProxy.instance.ensureStarted();
      expect(LocalStreamProxy.instance.port, portAfterConcurrent);
    });

    test('Retries transient 503 upstream chunk errors and delivers complete payload', () async {
      var chunk1Attempts = 0;
      final flakyServer = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => flakyServer.close(force: true));

      flakyServer.listen((req) async {
        final range = req.headers.value(HttpHeaders.rangeHeader) ?? '';
        final m = RegExp(r'bytes=(\d+)-(\d+)$').firstMatch(range);
        if (m == null) {
          req.response.statusCode = HttpStatus.forbidden;
          await req.response.close();
          return;
        }
        final start = int.parse(m.group(1)!);
        final end = int.parse(m.group(2)!);
        if (start >= LocalStreamProxy.chunkSizeBytes) {
          chunk1Attempts++;
          if (chunk1Attempts == 1) {
            req.response.statusCode = HttpStatus.serviceUnavailable;
            await req.response.close();
            return;
          }
        }
        final actualEnd = end >= payload.length ? payload.length - 1 : end;
        final slice = payload.sublist(start, actualEnd + 1);
        req.response.statusCode = HttpStatus.partialContent;
        req.response.headers.set(HttpHeaders.contentTypeHeader, 'audio/mp4');
        req.response.headers.set(
          HttpHeaders.contentRangeHeader,
          'bytes $start-$actualEnd/${payload.length}',
        );
        req.response.headers.set(HttpHeaders.contentLengthHeader, '${slice.length}');
        req.response.add(slice);
        await req.response.close();
      });

      final upstreamUrl = 'http://127.0.0.1:${flakyServer.port}/videoplayback?clen=${payload.length}&c=ANDROID';
      final proxyUrl = LocalStreamProxy.instance.registerUrl(upstreamUrl);

      final client = HttpClient();
      final req = await client.getUrl(Uri.parse(proxyUrl));
      final resp = await req.close();

      expect(resp.statusCode, HttpStatus.ok);
      final bytes = await resp.fold<List<int>>([], (acc, chunk) => acc..addAll(chunk));
      expect(bytes, payload);
      expect(chunk1Attempts, greaterThanOrEqualTo(2));
      client.close(force: true);
    });

    test('Prioritizes muxed itag 18 MP4 streams ahead of adaptive audio-only formats', () {
      final urls = YouTubeStreamService.selectPlayableStreamUrls({
        'formats': [
          {
            'itag': 18,
            'mimeType': 'video/mp4; codecs="avc1.42001E, mp4a.40.2"',
            'bitrate': 455000,
            'url': 'https://example.com/muxed18',
          },
        ],
        'adaptiveFormats': [
          {
            'itag': 140,
            'mimeType': 'audio/mp4; codecs="mp4a.40.2"',
            'bitrate': 129000,
            'url': 'https://example.com/audio140',
          },
          {
            'itag': 251,
            'mimeType': 'audio/webm; codecs="opus"',
            'bitrate': 160000,
            'url': 'https://example.com/audio251',
          },
        ],
      });

      expect(urls, [
        'https://example.com/muxed18',
        'https://example.com/audio140',
        'https://example.com/audio251',
      ]);
    });
  });
}
