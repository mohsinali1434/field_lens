import 'dart:async';

import 'package:field_lens/app/config/dependency_injection.dart';
import 'package:field_lens/app/router/app_routes.dart';
import 'package:field_lens/app/theme/app_radius.dart';
import 'package:field_lens/app/theme/app_shadows.dart';
import 'package:field_lens/app/theme/app_spacing.dart';
import 'package:field_lens/core/constants/app_constants.dart';
import 'package:field_lens/core/constants/setting_keys.dart';
import 'package:field_lens/core/extensions/context_extensions.dart';
import 'package:field_lens/core/widgets/animated_fade_slide.dart';
import 'package:field_lens/core/widgets/app_button.dart';
import 'package:field_lens/features/settings/domain/entities/setting_entity.dart';
import 'package:field_lens/features/settings/domain/repositories/settings_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Three-step onboarding flow for first-time users.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const List<_OnboardingStep> _steps = <_OnboardingStep>[
    _OnboardingStep(
      icon: Icons.assignment_outlined,
      title: 'Capture inspections',
      message: 'Create inspections, document sites, and keep everything organized offline.',
    ),
    _OnboardingStep(
      icon: Icons.photo_camera_outlined,
      title: 'Record observations',
      message: 'Add photos, voice notes, and structured observations as you walk the site.',
    ),
    _OnboardingStep(
      icon: Icons.description_outlined,
      title: 'Generate reports',
      message: 'Turn field data into professional PDF reports ready to share with clients.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await sl<SettingsRepository>().saveSetting(
      SettingEntity(
        key: SettingKeys.onboardingComplete,
        value: 'true',
        updatedAt: DateTime.now().toUtc(),
      ),
    );
    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  void _next() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: AppConstants.animationDuration,
        curve: Curves.easeInOut,
      );
      return;
    }
    unawaited(_completeOnboarding());
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _steps.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => unawaited(_completeOnboarding()),
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _steps.length,
                onPageChanged: (int index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (BuildContext context, int index) {
                  final step = _steps[index];
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: AnimatedFadeSlide(
                      index: index,
                      offsetY: 24,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          AnimatedSwitcher(
                            duration: AppConstants.animationDuration,
                            switchInCurve: Curves.easeOutBack,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                                  return ScaleTransition(
                                    scale: animation,
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  );
                                },
                            child: DecoratedBox(
                              key: ValueKey<IconData>(step.icon),
                              decoration: BoxDecoration(
                                gradient: context.appTheme.heroGradient,
                                borderRadius: AppRadius.xlRadius,
                                boxShadow: AppShadows.glow(
                                  context.appTheme.glow,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.xl),
                                child: Icon(
                                  step.icon,
                                  size: 72,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Text(
                            step.title,
                            style: context.textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            step.message,
                            style: context.textTheme.bodyLarge?.copyWith(
                              color: context.colors.onSurfaceVariant,
                              height: 1.55,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List<Widget>.generate(_steps.length, (int index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: AppConstants.animationDuration,
                        margin: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xxs,
                        ),
                        width: isActive ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: isActive
                              ? context.appTheme.heroGradient
                              : null,
                          color: isActive
                              ? null
                              : context.colors.outlineVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: isLast ? 'Get Started' : 'Next',
                    expand: true,
                    onPressed: _next,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingStep {
  const _OnboardingStep({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;
}
