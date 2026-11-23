import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../library/domain/music_repository.dart';

class SpotifyImportResult {
  final int totalImported;
  final int localMatches;
  final String playlistName;
  final List<String> matchedSongTitles;

  const SpotifyImportResult({
    required this.totalImported,
    required this.localMatches,
    required this.playlistName,
    required this.matchedSongTitles,
  });
}

class SpotifyImporter {
  final MusicRepository _repository;

  SpotifyImporter(this._repository);

  /// Imports tracks metadata from a Spotify Playlist / Liked Songs JSON export or API response
  /// and matches against existing local songs in the SunZara library.
  Future<SpotifyImportResult> importAndMatchJson(
    String jsonString, {
    String playlistName = 'Spotify Liked Songs',
  }) async {
    final localSongs = await _repository.getAllSongs();
    final matchedSongIds = <String>[];
    final matchedTitles = <String>[];

    final dynamic parsed = jsonDecode(jsonString);
    final List<dynamic> rawTracks = (parsed is List)
        ? parsed
        : (parsed['items'] as List? ?? parsed['tracks'] as List? ?? []);

    for (final item in rawTracks) {
      final track = (item['track'] is Map) ? item['track'] : item;
      final title = (track['name'] as String? ?? '').trim().toLowerCase();
      final artists = (track['artists'] as List? ?? [])
          .map((a) => (a['name'] as String? ?? '').trim().toLowerCase())
          .toList();

      if (title.isEmpty) continue;

      // Find best match in local library by title and artist
      for (final local in localSongs) {
        final localTitle = local.title.trim().toLowerCase();
        final localArtist = local.artist.trim().toLowerCase();

        final titleMatch = localTitle == title ||
            localTitle.contains(title) ||
            title.contains(localTitle);

        final artistMatch = artists.isEmpty ||
            artists.any((a) => localArtist.contains(a) || a.contains(localArtist));

        if (titleMatch && artistMatch) {
          if (!matchedSongIds.contains(local.id)) {
            matchedSongIds.add(local.id);
            matchedTitles.add(local.title);
            break;
          }
        }
      }
    }

    // Create a local playlist for these matched songs
    if (matchedSongIds.isNotEmpty) {
      await _repository.createPlaylist(playlistName);
      final playlists = await _repository.getAllPlaylists();
      final pl = playlists.firstWhere(
        (p) => p.name == playlistName,
        orElse: () => playlists.last,
      );

      for (final id in matchedSongIds) {
        await _repository.addSongToPlaylist(pl.id, id);
      }
    }

    return SpotifyImportResult(
      totalImported: rawTracks.length,
      localMatches: matchedSongIds.length,
      playlistName: playlistName,
      matchedSongTitles: matchedTitles,
    );
  }

  /// Optional: Fetches public playlist tracks via standard HTTP endpoint
  Future<SpotifyImportResult> importFromPublicEndpoint(
    String accessToken,
    String playlistId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/playlists/$playlistId/tracks?limit=100'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        return await importAndMatchJson(response.body);
      }
    } catch (_) {}

    return const SpotifyImportResult(
      totalImported: 0,
      localMatches: 0,
      playlistName: 'Spotify Import',
      matchedSongTitles: [],
    );
  }
}
