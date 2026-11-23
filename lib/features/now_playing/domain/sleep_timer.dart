import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../audio/presentation/playback_controller.dart';

class SleepTimerState {
  final bool isActive;
  final Duration remaining;
  final Duration total;
  final bool isEndOfTrack;

  const SleepTimerState({
    this.isActive = false,
    this.remaining = Duration.zero,
    this.total = Duration.zero,
    this.isEndOfTrack = false,
  });

  String get formattedRemaining {
    if (isEndOfTrack) return 'End of Track';
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class SleepTimerController extends ValueNotifier<SleepTimerState> {
  final PlaybackController _playbackController;
  Timer? _ticker;

  SleepTimerController(this._playbackController)
      : super(const SleepTimerState());

  void setTimer(Duration duration) {
    cancel();

    state = SleepTimerState(
      isActive: true,
      remaining: duration,
      total: duration,
      isEndOfTrack: false,
    );

    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remaining.inSeconds <= 1) {
        _triggerStop();
        return;
      }

      final newRemaining = state.remaining - const Duration(seconds: 1);
      state = SleepTimerState(
        isActive: true,
        remaining: newRemaining,
        total: state.total,
        isEndOfTrack: false,
      );
    });
  }

  void setEndOfTrack() {
    cancel();
    state = const SleepTimerState(
      isActive: true,
      isEndOfTrack: true,
    );

    // Watch for song change or completion
    void listener() {
      if (_playbackController.state.position.inSeconds >=
          _playbackController.state.duration.inSeconds - 1) {
        _playbackController.removeListener(listener);
        _triggerStop();
      }
    }

    _playbackController.addListener(listener);
  }

  void _triggerStop() {
    cancel();
    _playbackController.togglePlayPause();
  }

  void cancel() {
    _ticker?.cancel();
    _ticker = null;
    state = const SleepTimerState(isActive: false);
  }

  SleepTimerState get state => value;
  set state(SleepTimerState s) => value = s;

  @override
  void dispose() {
    cancel();
    super.dispose();
  }
}
