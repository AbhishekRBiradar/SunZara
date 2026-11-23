import '../../../core/models/playback_context.dart';
import '../../../core/models/queue_item.dart';
import '../../../core/models/song.dart';

class PlaybackStateModel {
  final Song? currentSong;
  final bool isPlaying;
  final bool isBuffering;
  final Duration position;
  final Duration duration;
  final double speed;
  final bool isShuffleEnabled;
  final RepeatMode repeatMode;
  final PlaybackContext context;
  final List<QueueItem> manualQueue;
  final List<QueueItem> automaticPool;
  final int? audioSessionId;

  const PlaybackStateModel({
    this.currentSong,
    this.isPlaying = false,
    this.isBuffering = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.speed = 1.0,
    this.isShuffleEnabled = true,
    this.repeatMode = RepeatMode.off,
    this.context = PlaybackContext.library,
    this.manualQueue = const [],
    this.automaticPool = const [],
    this.audioSessionId,
  });

  List<QueueItem> get fullUpcomingQueue => [
        ...manualQueue,
        ...automaticPool,
      ];

  double get progressFraction {
    if (duration.inMilliseconds == 0) return 0.0;
    return (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
  }

  PlaybackStateModel copyWith({
    Song? currentSong,
    bool? isPlaying,
    bool? isBuffering,
    Duration? position,
    Duration? duration,
    double? speed,
    bool? isShuffleEnabled,
    RepeatMode? repeatMode,
    PlaybackContext? context,
    List<QueueItem>? manualQueue,
    List<QueueItem>? automaticPool,
    int? audioSessionId,
    bool clearCurrentSong = false,
  }) {
    return PlaybackStateModel(
      currentSong: clearCurrentSong ? null : (currentSong ?? this.currentSong),
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      speed: speed ?? this.speed,
      isShuffleEnabled: isShuffleEnabled ?? this.isShuffleEnabled,
      repeatMode: repeatMode ?? this.repeatMode,
      context: context ?? this.context,
      manualQueue: manualQueue ?? this.manualQueue,
      automaticPool: automaticPool ?? this.automaticPool,
      audioSessionId: audioSessionId ?? this.audioSessionId,
    );
  }
}
