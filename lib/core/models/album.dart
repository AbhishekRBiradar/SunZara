class Album {
  final String id;
  final String title;
  final String artist;
  final int trackCount;
  final int totalDurationMs;
  final int? year;
  final String? artworkUri;

  const Album({
    required this.id,
    required this.title,
    required this.artist,
    required this.trackCount,
    required this.totalDurationMs,
    this.year,
    this.artworkUri,
  });

  String get formattedDuration {
    final totalSeconds = (totalDurationMs / 1000).round();
    final minutes = totalSeconds ~/ 60;
    final hours = minutes ~/ 60;
    if (hours > 0) {
      final remMinutes = minutes % 60;
      return '${hours}h ${remMinutes}m';
    }
    return '${minutes}m';
  }
}
