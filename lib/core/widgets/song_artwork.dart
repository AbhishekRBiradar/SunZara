import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/song.dart';
import '../theme/app_colors.dart';
import 'deterministic_artwork.dart';

/// Renders genuine embedded/system album artwork for a [Song].
/// Automatically queries native Android MediaStore / MediaMetadataRetriever,
/// caches extracted thumbnails in memory for smooth 60fps scrolling,
/// and deterministically falls back to [DeterministicArtwork] if no artwork exists.
class SongArtwork extends StatefulWidget {
  final Song song;
  final double size;
  final BorderRadius? borderRadius;
  final bool showGlow;

  const SongArtwork({
    super.key,
    required this.song,
    this.size = 56,
    this.borderRadius,
    this.showGlow = false,
  });

  // Global static cache to prevent redundant platform channel calls during scrolling
  static final Map<String, Uint8List?> _memoryCache = {};
  static final Set<String> _pendingRequests = {};
  static const MethodChannel _channel = MethodChannel('com.sunzara.app/mediastore');

  @override
  State<SongArtwork> createState() => _SongArtworkState();
}

class _SongArtworkState extends State<SongArtwork> {
  Uint8List? _artworkBytes;

  @override
  void initState() {
    super.initState();
    _resolveArtwork();
  }

  @override
  void didUpdateWidget(covariant SongArtwork oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.song.id != widget.song.id || oldWidget.size != widget.size) {
      _resolveArtwork();
    }
  }

  void _resolveArtwork() {
    final uri = widget.song.artworkUri;
    if (uri != null && (uri.startsWith('http://') || uri.startsWith('https://'))) {
      return;
    }

    final cacheKey = '${widget.song.id}_${widget.size > 150 ? "lg" : "sm"}';
    if (SongArtwork._memoryCache.containsKey(cacheKey)) {
      _artworkBytes = SongArtwork._memoryCache[cacheKey];
      return;
    }

    _fetchArtwork(cacheKey);
  }

  Future<void> _fetchArtwork(String cacheKey) async {
    if (SongArtwork._pendingRequests.contains(cacheKey)) return;
    SongArtwork._pendingRequests.add(cacheKey);

    try {
      final reqSize = widget.size > 150 ? 512 : 256;
      final dynamic result = await SongArtwork._channel.invokeMethod('getArtwork', {
        'id': widget.song.id,
        'filePath': widget.song.filePath,
        'size': reqSize,
      });

      if (result != null && result is Uint8List) {
        SongArtwork._memoryCache[cacheKey] = result;
        if (mounted) {
          setState(() {
            _artworkBytes = result;
          });
        }
      } else {
        SongArtwork._memoryCache[cacheKey] = null;
        if (mounted) {
          setState(() {
            _artworkBytes = null;
          });
        }
      }
    } catch (_) {
      SongArtwork._memoryCache[cacheKey] = null;
      if (mounted) {
        setState(() {
          _artworkBytes = null;
        });
      }
    } finally {
      SongArtwork._pendingRequests.remove(cacheKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(widget.size > 80 ? 16 : 8);

    final uri = widget.song.artworkUri;
    Widget imageContent;
    if (uri != null && (uri.startsWith('http://') || uri.startsWith('https://'))) {
      imageContent = Image.network(
        uri,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildFallback(),
      );
    } else if (_artworkBytes != null) {
      imageContent = Image.memory(
        _artworkBytes!,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => _buildFallback(),
      );
    } else {
      imageContent = _buildFallback();
    }

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: widget.showGlow
            ? [
                BoxShadow(
                  color: AppColors.primaryGlow,
                  blurRadius: 18,
                  spreadRadius: 2,
                  offset: Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: imageContent,
      ),
    );
  }

  Widget _buildFallback() {
    return DeterministicArtwork(
      seed: '${widget.song.title} ${widget.song.artist}',
      size: widget.size,
      borderRadius: widget.borderRadius,
    );
  }
}
