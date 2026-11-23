import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import '../../../core/models/song.dart';
import '../domain/music_repository.dart';

enum ScanStage {
  idle,
  requestingPermissions,
  queryingStorage,
  parsingMetadata,
  syncingDatabase,
  completed,
  permissionDenied,
  error,
}

class ScanProgress {
  final ScanStage stage;
  final int count;
  final int total;
  final String message;

  const ScanProgress({
    required this.stage,
    this.count = 0,
    this.total = 0,
    this.message = '',
  });

  double get progressFraction => total > 0 ? (count / total).clamp(0.0, 1.0) : 0.0;
}

class MediaStoreScanner {
  static const MethodChannel _channel = MethodChannel('com.sunzara.app/mediastore');

  final MusicRepository _repository;
  final StreamController<ScanProgress> _progressController =
      StreamController<ScanProgress>.broadcast();

  bool _isScanning = false;
  bool _cancelRequested = false;

  MediaStoreScanner(this._repository);

  Stream<ScanProgress> get progressStream => _progressController.stream;
  bool get isScanning => _isScanning;

  void cancelScan() {
    _cancelRequested = true;
  }

  /// Initiates the full music scanning workflow:
  /// 1. Requests permissions
  /// 2. Queries MediaStore (Android) or directory walk (Desktop)
  /// 3. Normalizes metadata and pairs .lrc
  /// 4. Incrementally syncs database
  Future<List<Song>> scanMusic({List<String>? excludedFolders}) async {
    if (_isScanning) return [];
    _isScanning = true;
    _cancelRequested = false;

    try {
      _emit(const ScanProgress(
        stage: ScanStage.requestingPermissions,
        message: 'Checking storage permissions...',
      ));

      final hasPermission = await requestMediaPermissions();
      if (!hasPermission) {
        _emit(const ScanProgress(
          stage: ScanStage.permissionDenied,
          message: 'Storage permission denied. Please grant permission to scan music.',
        ));
        _isScanning = false;
        return [];
      }

      if (_cancelRequested) return [];

      _emit(const ScanProgress(
        stage: ScanStage.queryingStorage,
        message: 'Discovering audio files on device...',
      ));

      List<Song> rawSongs = [];

      if (Platform.isAndroid) {
        rawSongs = await _scanFromMediaStore();
        if (rawSongs.isEmpty && !_cancelRequested) {
          final fallbackSongs = await _scanFromLocalFilesystem();
          rawSongs.addAll(fallbackSongs);
        }
      } else {
        rawSongs = await _scanFromLocalFilesystem();
      }

      if (_cancelRequested) return [];

      // Filter excluded folders and system directories
      final filteredSongs = _filterSongs(rawSongs, excludedFolders ?? []);

      _emit(ScanProgress(
        stage: ScanStage.syncingDatabase,
        count: 0,
        total: filteredSongs.length,
        message: 'Syncing ${filteredSongs.length} tracks to library...',
      ));

      // Batch insert / update into database
      await _repository.insertSongsBatch(filteredSongs);

      // Clean up songs that were deleted from storage
      final currentPaths = filteredSongs.map((s) => s.filePath).toList();
      await _repository.deleteMissingSongs(currentPaths);

      _emit(ScanProgress(
        stage: ScanStage.completed,
        count: filteredSongs.length,
        total: filteredSongs.length,
        message: 'Discovered ${filteredSongs.length} tracks.',
      ));

      return filteredSongs;
    } catch (e) {
      _emit(ScanProgress(
        stage: ScanStage.error,
        message: 'Scan error: ${e.toString()}',
      ));
      return [];
    } finally {
      _isScanning = false;
    }
  }

  /// Requests appropriate permissions according to Android version
  Future<bool> requestMediaPermissions() async {
    if (!Platform.isAndroid) return true;

    try {
      // Check if already granted
      final audioGranted = await Permission.audio.isGranted || await Permission.audio.isLimited;
      final storageGranted = await Permission.storage.isGranted || await Permission.storage.isLimited;
      if (audioGranted || storageGranted) return true;

      // Check Android 13+ (API 33+) audio permission
      final audioStatus = await Permission.audio.request();
      if (audioStatus.isGranted || audioStatus.isLimited) return true;

      // Fall back to legacy storage permission for Android 10-12
      final storageStatus = await Permission.storage.request();
      if (storageStatus.isGranted || storageStatus.isLimited) return true;

      // Check manageExternalStorage if on Android 11+
      if (await Permission.manageExternalStorage.isGranted) return true;

      return (await Permission.audio.isGranted ||
          await Permission.storage.isGranted ||
          await Permission.manageExternalStorage.isGranted);
    } catch (_) {
      return true;
    }
  }

  /// Queries Android native MediaStore via MethodChannel
  Future<List<Song>> _scanFromMediaStore() async {
    try {
      final List<dynamic>? results =
          await _channel.invokeListMethod<dynamic>('queryAudio');
      if (results == null || results.isEmpty) return [];

      final songs = <Song>[];
      for (var i = 0; i < results.length; i++) {
        if (_cancelRequested) break;

        try {
          final map = Map<String, dynamic>.from(results[i] as Map);
          final rawTitle = map['title'] as String? ?? '';
          final rawArtist = map['artist'] as String? ?? '';
          final filePath = map['filePath'] as String? ?? '';

          final normalized = _normalizeMetadata(rawTitle, rawArtist, filePath);

          final song = Song(
            id: map['id']?.toString() ?? 'ms_${filePath.hashCode}',
            title: normalized.title,
            artist: normalized.artist,
            album: (map['album'] as String?)?.isNotEmpty == true
                ? map['album'] as String
                : 'Unknown Album',
            albumArtist: map['albumArtist'] as String?,
            genre: map['genre'] as String?,
            year: (map['year'] as num?)?.toInt(),
            trackNumber: (map['trackNumber'] as num?)?.toInt(),
            durationMs: (map['durationMs'] as num?)?.toInt() ?? 0,
            fileSize: (map['fileSize'] as num?)?.toInt() ?? 0,
            filePath: filePath,
            folder: map['folder'] as String? ?? 'Music',
            dateAdded: map['dateAdded'] != null
                ? DateTime.fromMillisecondsSinceEpoch(
                    (map['dateAdded'] as num).toInt())
                : null,
            dateModified: map['dateModified'] != null
                ? DateTime.fromMillisecondsSinceEpoch(
                    (map['dateModified'] as num).toInt())
                : null,
            artworkUri: map['artworkUri'] as String?,
            lrcPath: map['lrcPath'] as String?,
          );

          songs.add(song);

          if (i % 20 == 0) {
            _emit(ScanProgress(
              stage: ScanStage.parsingMetadata,
              count: i + 1,
              total: results.length,
              message: 'Scanning track ${i + 1} of ${results.length}...',
            ));
          }
        } catch (_) {}
      }

      return songs;
    } catch (e) {
      // Graceful fallback to local filesystem scanning without crashing the scan workflow
      return [];
    }
  }

  /// Local filesystem scanner fallback for comprehensive file discovery
  Future<List<Song>> _scanFromLocalFilesystem() async {
    final supportedExtensions = {
      '.mp3',
      '.flac',
      '.wav',
      '.aac',
      '.m4a',
      '.ogg',
      '.opus',
      '.wma'
    };

    final scanDirs = <Directory>[];

    // Check Android storage directories
    if (Platform.isAndroid) {
      final androidCommonDirs = [
        '/storage/emulated/0/Music',
        '/storage/emulated/0/Download',
        '/storage/emulated/0/Downloads',
        '/storage/emulated/0/Audio',
        '/storage/emulated/0/Songs',
        '/storage/emulated/0/Sounds',
        '/storage/emulated/0/Podcasts',
        '/storage/emulated/0/Recordings',
        '/storage/emulated/0/Telegram',
        '/storage/emulated/0/WhatsApp/Media/WhatsApp Audio',
        '/sdcard/Music',
        '/sdcard/Download',
        '/sdcard/Downloads',
        '/sdcard/Audio',
      ];
      for (final dirPath in androidCommonDirs) {
        final d = Directory(dirPath);
        if (d.existsSync()) scanDirs.add(d);
      }

      // Also scan root /storage/emulated/0 non-system folders
      try {
        final rootDir = Directory('/storage/emulated/0');
        if (rootDir.existsSync()) {
          final entries = rootDir.listSync(followLinks: false);
          for (final entry in entries) {
            if (entry is Directory) {
              final name = p.basename(entry.path).toLowerCase();
              if (name != 'android' &&
                  !name.startsWith('.') &&
                  !scanDirs.any((d) => d.path == entry.path)) {
                scanDirs.add(entry);
              }
            }
          }
        }
      } catch (_) {}
    }

    // Check standard user Music directory
    final userHome = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'];
    if (userHome != null) {
      final musicDir = Directory(p.join(userHome, 'Music'));
      if (musicDir.existsSync()) scanDirs.add(musicDir);
    }

    // Check project test_assets if exists
    final testAssets = Directory(p.join(Directory.current.path, 'test_assets'));
    if (testAssets.existsSync()) scanDirs.add(testAssets);

    final songs = <Song>[];
    for (final dir in scanDirs) {
      if (_cancelRequested) break;

      try {
        await for (final entity in dir.list(recursive: true, followLinks: false)) {
          if (_cancelRequested) break;
          if (entity is! File) continue;

          final ext = p.extension(entity.path).toLowerCase();
          if (!supportedExtensions.contains(ext)) continue;

          final stat = entity.statSync();
          final fileName = p.basenameWithoutExtension(entity.path);
          final folderName = p.basename(p.dirname(entity.path));
          final normalized = _normalizeMetadata('', '', entity.path);

          // Check for .lrc in same dir
          final lrcFile = File(p.setExtension(entity.path, '.lrc'));
          final lrcPath = lrcFile.existsSync() ? lrcFile.path : null;

          final song = Song(
            id: 'fs_${entity.path.hashCode}',
            title: normalized.title.isNotEmpty ? normalized.title : fileName,
            artist: normalized.artist.isNotEmpty ? normalized.artist : 'Unknown Artist',
            album: folderName,
            durationMs: 180000, // estimated
            fileSize: stat.size,
            filePath: entity.path,
            folder: folderName,
            dateAdded: stat.changed,
            dateModified: stat.modified,
            lrcPath: lrcPath,
          );
          songs.add(song);
        }
      } catch (e) {
        // Skip unreadable directories
      }
    }

    return songs;
  }

  /// Normalizes metadata: if title or artist is empty, parses "Artist - Title" from filename
  _NormalizedMetadata _normalizeMetadata(String rawTitle, String rawArtist, String filePath) {
    var title = rawTitle.trim();
    var artist = rawArtist.trim();

    final isTitleUnknown = title.isEmpty ||
        title.toLowerCase() == 'unknown' ||
        title.toLowerCase() == '<unknown>';
    final isArtistUnknown = artist.isEmpty ||
        artist.toLowerCase() == 'unknown' ||
        artist.toLowerCase() == '<unknown>';

    if ((isTitleUnknown || isArtistUnknown) && filePath.isNotEmpty) {
      final baseName = p.basenameWithoutExtension(filePath);
      if (baseName.contains(' - ')) {
        final parts = baseName.split(' - ');
        if (parts.length >= 2) {
          if (isArtistUnknown) artist = parts[0].trim();
          if (isTitleUnknown) title = parts.sublist(1).join(' - ').trim();
        }
      } else if (isTitleUnknown) {
        title = baseName.trim();
      }
    }

    if (title.isEmpty) title = 'Unknown Track';
    if (artist.isEmpty) artist = 'Unknown Artist';

    return _NormalizedMetadata(title: title, artist: artist);
  }

  /// Filters out noisy system folders and user-excluded directories
  List<Song> _filterSongs(List<Song> songs, List<String> userExcludedFolders) {
    const systemBlacklist = [
      'android/data',
      'android/obb',
      'ringtones',
      'notifications',
      'alarms',
      '.thumbnails',
      'whatsapp/media/.statuses',
      'podbean',
    ];

    return songs.where((s) {
      final pathLower = s.filePath.toLowerCase().replaceAll('\\', '/');
      final folderLower = s.folder.toLowerCase();

      // Check system blacklist
      for (final blocked in systemBlacklist) {
        if (pathLower.contains(blocked)) return false;
      }

      // Check user excluded folders
      for (final excluded in userExcludedFolders) {
        if (folderLower == excluded.toLowerCase() ||
            pathLower.contains(excluded.toLowerCase())) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _emit(ScanProgress progress) {
    if (!_progressController.isClosed) {
      _progressController.add(progress);
    }
  }

  void dispose() {
    _progressController.close();
  }
}

class _NormalizedMetadata {
  final String title;
  final String artist;

  const _NormalizedMetadata({required this.title, required this.artist});
}
