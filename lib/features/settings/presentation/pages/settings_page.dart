import 'package:field_lens/app/config/dependency_injection.dart';
import 'package:field_lens/app/router/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:field_lens/app/theme/app_spacing.dart';
import 'package:field_lens/core/extensions/context_extensions.dart';
import 'package:field_lens/core/services/backup_service.dart';
import 'package:field_lens/core/widgets/animated_fade_slide.dart';
import 'package:field_lens/core/widgets/app_button.dart';
import 'package:field_lens/core/widgets/app_card.dart';
import 'package:field_lens/core/widgets/app_page_header.dart';
import 'package:field_lens/core/widgets/app_section_header.dart';
import 'package:field_lens/features/settings/presentation/bloc/theme_cubit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Application settings screen.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isExporting = false;

  Future<void> _exportBackup() async {
    setState(() => _isExporting = true);
    final export = await sl<BackupService>().exportBackup();
    if (!mounted) return;

    await export.fold(
      onSuccess: (path) async {
        final share = await sl<BackupService>().shareBackup(path);
        if (!mounted) return;
        setState(() => _isExporting = false);
        share.fold(
          onSuccess: (_) {},
          onFailure: (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(failure.message)),
            );
          },
        );
      },
      onFailure: (failure) {
        setState(() => _isExporting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: <Widget>[
          const AnimatedFadeSlide(
            child: AppPageHeader(
              title: 'Settings',
              subtitle: 'Customize appearance and manage your data',
              compact: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const AnimatedFadeSlide(
                  index: 1,
                  child: AppSectionHeader(title: 'Appearance'),
                ),
                AnimatedFadeSlide(
                  index: 2,
                  child: BlocBuilder<ThemeCubit, ThemeMode>(
                  bloc: sl<ThemeCubit>(),
                  builder: (BuildContext context, ThemeMode themeMode) {
                    return AppCard(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: SegmentedButton<ThemeMode>(
                        segments: const <ButtonSegment<ThemeMode>>[
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.system,
                            label: Text('System'),
                            icon: Icon(Icons.brightness_auto_rounded),
                          ),
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.light,
                            label: Text('Light'),
                            icon: Icon(Icons.light_mode_rounded),
                          ),
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.dark,
                            label: Text('Dark'),
                            icon: Icon(Icons.dark_mode_rounded),
                          ),
                        ],
                        selected: <ThemeMode>{themeMode},
                        onSelectionChanged: (Set<ThemeMode> selection) {
                          sl<ThemeCubit>().setThemeMode(selection.first);
                        },
                      ),
                    );
                  },
                ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const AnimatedFadeSlide(
                  index: 3,
                  child: AppSectionHeader(title: 'Data'),
                ),
                AnimatedFadeSlide(
                  index: 4,
                  child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        'Export a ZIP backup of inspections and settings.',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppButton(
                        label: 'Export Backup',
                        icon: Icons.archive_outlined,
                        expand: true,
                        isLoading: _isExporting,
                        onPressed: _isExporting ? null : _exportBackup,
                      ),
                    ],
                  ),
                ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const AnimatedFadeSlide(
                  index: 5,
                  child: AppSectionHeader(title: 'Privacy'),
                ),
                AnimatedFadeSlide(
                  index: 6,
                  child: AppCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        Icons.shield_outlined,
                        color: context.colors.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Your inspection data stays on your device unless you '
                          'explicitly export or synchronize it.',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colors.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const AnimatedFadeSlide(
                  index: 7,
                  child: AppSectionHeader(title: 'About'),
                ),
                AnimatedFadeSlide(
                  index: 8,
                  child: AppCard(
                  child: Material(
                    color: Colors.transparent,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.school_outlined,
                        color: context.colors.primary,
                      ),
                      title: const Text('View onboarding'),
                      subtitle: const Text('Replay the getting started tour'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.push(AppRoutes.onboarding),
                    ),
                  ),
                ),
                ),
              ],
            ),
          ),
        ],
    );
  }
}
