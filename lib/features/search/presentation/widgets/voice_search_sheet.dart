import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class VoiceSessionEvent {
  final String type;
  final String? text;
  final double? rms;
  final int? errorCode;

  const VoiceSessionEvent({
    required this.type,
    this.text,
    this.rms,
    this.errorCode,
  });

  factory VoiceSessionEvent.fromMap(dynamic raw) {
    final map = Map<dynamic, dynamic>.from(raw as Map);
    return VoiceSessionEvent(
      type: map['type'] as String? ?? '',
      text: map['text'] as String?,
      rms: (map['rms'] as num?)?.toDouble(),
      errorCode: (map['code'] as num?)?.toInt(),
    );
  }
}

/// Custom SunZara-themed voice command modal sheet with live reactive audio bars
/// and real-time partial transcription.
class VoiceSearchSheet extends StatefulWidget {
  final Stream<VoiceSessionEvent> events;
  final Future<bool> Function() onStartListening;
  final Future<void> Function() onStopListening;
  final String prompt;

  const VoiceSearchSheet({
    super.key,
    required this.events,
    required this.onStartListening,
    required this.onStopListening,
    this.prompt = 'Say a song or artist name',
  });

  @override
  State<VoiceSearchSheet> createState() => _VoiceSearchSheetState();
}

class _VoiceSearchSheetState extends State<VoiceSearchSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  StreamSubscription<VoiceSessionEvent>? _sub;

  String _partialText = '';
  String _statusLabel = 'Listening...';
  String? _errorText;
  double _normalizedLevel = 0.2;
  bool _isReady = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _sub = widget.events.listen(_handleEvent);
    _begin();
  }

  Future<void> _begin() async {
    if (!_pulseController.isAnimating) {
      _pulseController.repeat();
    }
    setState(() {
      _errorText = null;
      _partialText = '';
      _statusLabel = 'Warming up mic...';
      _isReady = false;
    });
    final ok = await widget.onStartListening();
    if (!ok && mounted) {
      Navigator.of(context).pop(null);
    }
  }

  void _handleEvent(VoiceSessionEvent ev) {
    if (!mounted || _completed) return;
    switch (ev.type) {
      case 'ready':
        setState(() {
          _isReady = true;
          _errorText = null;
          _statusLabel = 'सुन ज़रा • Listening...';
        });
        break;
      case 'rms':
        final rms = ev.rms ?? 0.0;
        // Android rmsdB typically spans roughly -2 to +12 dB
        final clamped = ((rms + 2.0) / 12.0).clamp(0.08, 1.0);
        setState(() => _normalizedLevel = clamped);
        break;
      case 'partial':
        final txt = (ev.text ?? '').trim();
        if (txt.isNotEmpty) {
          setState(() => _partialText = txt);
        }
        break;
      case 'result':
        final finalTxt = (ev.text ?? '').trim();
        _completed = true;
        _pulseController.stop();
        setState(() {
          _partialText = finalTxt;
          _statusLabel = finalTxt.isNotEmpty ? 'Got it!' : 'Didn\'t catch that';
          _normalizedLevel = 0.25;
        });
        Future<void>.delayed(const Duration(milliseconds: 220), () {
          if (mounted) {
            Navigator.of(context).pop(finalTxt.isEmpty ? null : finalTxt);
          }
        });
        break;
      case 'error':
        _pulseController.stop();
        setState(() {
          _isReady = false;
          _normalizedLevel = 0.12;
          _statusLabel = 'Tap mic to try again';
          _errorText = _friendlyError(ev.errorCode);
        });
        break;
    }
  }

  String _friendlyError(int? code) {
    switch (code) {
      case 6: // ERROR_SPEECH_TIMEOUT
      case 7: // ERROR_NO_MATCH
        return 'No speech detected. Speak clearly near the mic.';
      case 2: // ERROR_NETWORK
      case 1: // ERROR_NETWORK_TIMEOUT
        return 'Network needed for voice recognition.';
      case 9: // ERROR_INSUFFICIENT_PERMISSIONS
        return 'Microphone permission required for voice search.';
      default:
        return 'Couldn\'t recognize speech right now.';
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _pulseController.dispose();
    widget.onStopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _errorText != null;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: AppColors.primary.withAlpha(90), width: 1.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(45),
            blurRadius: 28,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        20 + MediaQuery.of(context).viewPadding.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 14),

            // Brand badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(24),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withAlpha(75)),
              ),
              child: Text(
                _statusLabel,
                style: AppTypography.hindiSubtitle.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Glowing reactive SunZara orb
            SizedBox(
              height: 118,
              width: 118,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final t = _pulseController.value;
                  final wave = 0.85 + 0.15 * math.sin(t * 2 * math.pi);
                  final scale1 = hasError ? 1.0 : (1.0 + 0.34 * _normalizedLevel * t);
                  final scale2 = hasError ? 1.0 : (1.0 + 0.22 * _normalizedLevel * wave);

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      if (!hasError) ...[
                        Transform.scale(
                          scale: scale1,
                          child: Container(
                            width: 86,
                            height: 86,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withAlpha(((1.0 - t) * 55).round()),
                            ),
                          ),
                        ),
                        Transform.scale(
                          scale: scale2,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withAlpha(110),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                      GestureDetector(
                        onTap: hasError ? _begin : null,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: hasError
                                  ? [AppColors.surface, AppColors.surfaceHighlight]
                                  : [AppColors.primaryGlow, AppColors.primary],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (hasError ? AppColors.error : AppColors.primary)
                                    .withAlpha(110),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            hasError ? Icons.refresh_rounded : Icons.mic_rounded,
                            size: 34,
                            color: hasError ? AppColors.primary : AppColors.background,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Reactive frequency wave bars
            const SizedBox(height: 10),
            SizedBox(
              height: 26,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(9, (idx) {
                      final distFromCenter = (idx - 4).abs();
                      final envelope = 1.0 - (distFromCenter * 0.16);
                      final osc = 0.5 +
                          0.5 * math.sin((_pulseController.value * 2 * math.pi) + idx * 0.65);
                      final h = hasError
                          ? 5.0
                          : (6.0 + 18.0 * _normalizedLevel * envelope * (0.45 + 0.55 * osc));
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 80),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 4,
                        height: h.clamp(5.0, 24.0),
                        decoration: BoxDecoration(
                          color: hasError
                              ? AppColors.textMuted
                              : AppColors.primary.withAlpha(_isReady ? 235 : 130),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),

            // Live recognized text or prompt
            Text(
              hasError
                  ? _errorText!
                  : (_partialText.isNotEmpty ? '"$_partialText"' : widget.prompt),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: (_partialText.isNotEmpty && !hasError
                      ? AppTypography.headingSmall
                      : AppTypography.body)
                  .copyWith(
                color: hasError
                    ? AppColors.error
                    : (_partialText.isNotEmpty
                        ? AppColors.textPrimary
                        : AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasError) ...[
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    icon: const Icon(Icons.mic_rounded, size: 18),
                    label: const Text('Try Again'),
                    onPressed: _begin,
                  ),
                  const SizedBox(width: 12),
                ],
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: BorderSide(color: AppColors.divider),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                  ),
                  onPressed: () => Navigator.of(context).pop(null),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
