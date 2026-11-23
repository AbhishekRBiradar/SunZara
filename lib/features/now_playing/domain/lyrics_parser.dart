import 'dart:io';

class LyricLine {
  final Duration timestamp;
  final String text;

  const LyricLine({required this.timestamp, required this.text});
}

class LyricsData {
  final List<LyricLine> lines;
  final bool isSynced;
  final String? rawText;

  const LyricsData({
    required this.lines,
    this.isSynced = false,
    this.rawText,
  });

  static LyricsData empty() => const LyricsData(lines: [], isSynced: false);

  /// Parses .lrc content string
  static LyricsData parseLrc(String content) {
    final lines = <LyricLine>[];
    final regex = RegExp(r'\[(\d+):(\d+(?:\.\d+)?)\](.*)');

    final rawLines = content.split('\n');
    for (final line in rawLines) {
      final match = regex.firstMatch(line.trim());
      if (match != null) {
        final minutes = int.tryParse(match.group(1) ?? '0') ?? 0;
        final secondsDouble = double.tryParse(match.group(2) ?? '0') ?? 0.0;
        final text = (match.group(3) ?? '').trim();

        final totalMs = ((minutes * 60 + secondsDouble) * 1000).round();
        lines.add(LyricLine(
          timestamp: Duration(milliseconds: totalMs),
          text: text,
        ));
      }
    }

    if (lines.isNotEmpty) {
      lines.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return LyricsData(lines: lines, isSynced: true, rawText: content);
    }

    // Fall back to plain text if no timestamps matched
    final plainLines = rawLines
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty && !l.startsWith('['))
        .map((l) => LyricLine(timestamp: Duration.zero, text: l))
        .toList();

    return LyricsData(lines: plainLines, isSynced: false, rawText: content);
  }

  /// Loads lyrics from an .lrc file path if existing
  static Future<LyricsData> fromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final content = await file.readAsString();
        return parseLrc(content);
      }
    } catch (_) {}
    return LyricsData.empty();
  }

  /// Returns active lyric line index for current playback position
  int getActiveLineIndex(Duration position) {
    if (lines.isEmpty || !isSynced) return -1;

    for (var i = lines.length - 1; i >= 0; i--) {
      if (position >= lines[i].timestamp) {
        return i;
      }
    }
    return 0;
  }
}
