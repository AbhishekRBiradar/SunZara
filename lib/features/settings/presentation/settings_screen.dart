import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/services/app_version_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/sunzara_theme_preset.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/sunzara_logo.dart';
import '../../audio/presentation/playback_controller.dart';
import '../../library/data/mediastore_scanner.dart';
import '../../library/domain/music_repository.dart';

class SettingsScreen extends StatefulWidget {
  final MusicRepository repository;
  final PlaybackController playbackController;
  final MediaStoreScanner scanner;

  const SettingsScreen({
    super.key,
    required this.repository,
    required this.playbackController,
    required this.scanner,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final Future<AppVersionInfo> _versionFuture;

  @override
  void initState() {
    super.initState();
    _versionFuture = AppVersionService.instance.getVersionInfo();
  }

  void _triggerScan() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StreamBuilder<ScanProgress>(
          stream: widget.scanner.progressStream,
          builder: (context, snapshot) {
            final progress = snapshot.data;
            final isDone = progress?.stage == ScanStage.completed ||
                progress?.stage == ScanStage.permissionDenied ||
                progress?.stage == ScanStage.error;

            return AlertDialog(
              backgroundColor: AppColors.surfaceElevated,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(Icons.sync_rounded, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text('Scanning Storage', style: AppTypography.headingSmall),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    progress?.message ?? 'Searching for audio files...',
                    style: AppTypography.body,
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: progress?.progressFraction,
                    backgroundColor: AppColors.divider,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  if (progress != null && progress.total > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${progress.count} / ${progress.total} tracks',
                        style: AppTypography.caption,
                      ),
                    ),
                ],
              ),
              actions: [
                if (!isDone)
                  TextButton(
                    onPressed: () {
                      widget.scanner.cancelScan();
                      Navigator.pop(context);
                    },
                    child: Text('Cancel', style: TextStyle(color: AppColors.error)),
                  )
                else
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Done', style: TextStyle(color: AppColors.primary)),
                  ),
              ],
            );
          },
        );
      },
    );

    widget.scanner.scanMusic();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (context, _) {
        final isDark = ThemeController.instance.isDarkMode;
        final currentPreset = ThemeController.instance.currentPreset;
        final activePalette = ThemeController.instance.activePalette;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text('Settings', style: AppTypography.headingMedium),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              // Appearance
              _buildCategoryHeader('APPEARANCE & THEMES'),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider, width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Theme Preset Dropdown
                    Text(
                      'SELECT THEME',
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<SunZaraThemePreset>(
                      value: currentPreset,
                      dropdownColor: AppColors.surfaceElevated,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.surfaceElevated,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.divider, width: 0.8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.divider, width: 0.8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                      ),
                      icon: Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary, size: 28),
                      items: SunZaraThemePreset.values.map((preset) {
                        return DropdownMenuItem<SunZaraThemePreset>(
                          value: preset,
                          child: Row(
                            children: [
                              Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: preset.primaryAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                preset.displayName,
                                style: AppTypography.body.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (newPreset) {
                        if (newPreset != null) {
                          ThemeController.instance.setPreset(newPreset);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Light / Dark Switch for the selected theme
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isDark ? 'Dark Mode' : 'Light Mode',
                                  style: AppTypography.songTitle,
                                ),
                                Text(
                                  'Active: ${activePalette.name} (${isDark ? "Dark" : "Light"})',
                                  style: AppTypography.caption,
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: isDark,
                            activeTrackColor: AppColors.surfaceHighlight,
                            activeThumbColor: AppColors.primary,
                            inactiveTrackColor: AppColors.surface,
                            inactiveThumbColor: AppColors.primary,
                            onChanged: (val) {
                              ThemeController.instance.setDarkMode(val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          Divider(color: AppColors.divider),

          // Playback
          _buildCategoryHeader('PLAYBACK'),
          ListTile(
            leading: Icon(Icons.notifications_active_rounded, color: AppColors.primary),
            title: Text('Lock Screen & Notification Controls', style: AppTypography.body),
            subtitle: Text('Tap to enable media notification permissions', style: AppTypography.caption),
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              final status = await Permission.notification.request();
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    status.isGranted
                        ? 'Notification controls enabled!'
                        : 'Notification permission is ${status.name}',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.shuffle_rounded, color: AppColors.primary),
            title: Text('Default Auto Shuffle', style: AppTypography.body),
            subtitle: Text('ON (Prevents unwanted repetition)', style: AppTypography.caption),
          ),
          ListTile(
            leading: Icon(Icons.restore_rounded, color: AppColors.primary),
            title: Text('Resume on Launch', style: AppTypography.body),
            subtitle: Text('Restores previous track & position (paused)', style: AppTypography.caption),
          ),
          Divider(color: AppColors.divider),

          // Library
          _buildCategoryHeader('LIBRARY'),
          ListTile(
            leading: Icon(Icons.sync_rounded, color: AppColors.primary),
            title: Text('Rescan Music Library', style: AppTypography.body),
            subtitle: Text('Scan MediaStore for new or changed music', style: AppTypography.caption),
            onTap: _triggerScan,
          ),
          Divider(color: AppColors.divider),

          // Privacy
          _buildCategoryHeader('PRIVACY'),
          ListTile(
            leading: Icon(Icons.security_rounded, color: AppColors.primary),
            title: Text('Local-Only Storage', style: AppTypography.body),
            subtitle: Text('Zero tracking, zero cloud telemetry, no accounts', style: AppTypography.caption),
          ),
          Divider(color: AppColors.divider),

          // About
          _buildCategoryHeader('ABOUT'),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider, width: 0.6),
            ),
            child: Row(
              children: [
                const SunZaraLogo(size: 46),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SunZara (सुन ज़रा)', style: AppTypography.songTitle.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('Your music. Your world.', style: AppTypography.caption),
                      const SizedBox(height: 2),
                      FutureBuilder<AppVersionInfo>(
                        future: _versionFuture,
                        initialData: AppVersionInfo.fallback,
                        builder: (context, snapshot) {
                          final version = snapshot.data ?? AppVersionInfo.fallback;
                          return Text(
                            '${version.displayLabel} • Offline & Online Player',
                            style: AppTypography.caption.copyWith(color: AppColors.primary),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
      },
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6, left: 4),
      child: Text(
        title,
        style: AppTypography.caption.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
          fontSize: 11,
        ),
      ),
    );
  }
}

