import 'package:field_lens/app/theme/app_colors.dart';
import 'package:material_ui/material_ui.dart';

/// Custom design tokens beyond [ThemeData].
@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.heroGradient,
    required this.accentGradient,
    required this.cardBorder,
    required this.glow,
    required this.navBackground,
  });

  final Gradient heroGradient;
  final Gradient accentGradient;
  final Color cardBorder;
  final Color glow;
  final Color navBackground;

  static AppThemeExtension light(ColorScheme scheme) {
    return AppThemeExtension(
      heroGradient: AppColors.heroGradientLight,
      accentGradient: AppColors.accentGradient,
      cardBorder: scheme.outlineVariant.withValues(alpha: 0.35),
      glow: AppColors.primary.withValues(alpha: 0.18),
      navBackground: AppColors.lightSurface.withValues(alpha: 0.92),
    );
  }

  static AppThemeExtension dark(ColorScheme scheme) {
    return AppThemeExtension(
      heroGradient: AppColors.heroGradientDark,
      accentGradient: AppColors.accentGradient,
      cardBorder: scheme.outlineVariant.withValues(alpha: 0.25),
      glow: AppColors.secondary.withValues(alpha: 0.22),
      navBackground: AppColors.darkSurface.withValues(alpha: 0.92),
    );
  }

  @override
  AppThemeExtension copyWith({
    Gradient? heroGradient,
    Gradient? accentGradient,
    Color? cardBorder,
    Color? glow,
    Color? navBackground,
  }) {
    return AppThemeExtension(
      heroGradient: heroGradient ?? this.heroGradient,
      accentGradient: accentGradient ?? this.accentGradient,
      cardBorder: cardBorder ?? this.cardBorder,
      glow: glow ?? this.glow,
      navBackground: navBackground ?? this.navBackground,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      heroGradient: heroGradient,
      accentGradient: accentGradient,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      glow: Color.lerp(glow, other.glow, t)!,
      navBackground: Color.lerp(navBackground, other.navBackground, t)!,
    );
  }
}
