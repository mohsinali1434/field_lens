import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

/// Typography scale for FieldLens using Plus Jakarta Sans.
abstract final class AppTypography {
  static TextTheme textTheme(TextTheme base) {
    final fontFamily = GoogleFonts.plusJakartaSans().fontFamily;

    TextStyle? style(
      TextStyle? source, {
      FontWeight? fontWeight,
      double? letterSpacing,
      double? height,
    }) {
      return source?.copyWith(
        fontFamily: fontFamily,
        fontWeight: fontWeight ?? source.fontWeight,
        letterSpacing: letterSpacing,
        height: height,
      );
    }

    return base.copyWith(
      displayLarge: style(
        base.displayLarge,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.2,
        height: 1.1,
      ),
      displayMedium: style(
        base.displayMedium,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        height: 1.15,
      ),
      headlineLarge: style(
        base.headlineLarge,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineMedium: style(
        base.headlineMedium,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      headlineSmall: style(base.headlineSmall, fontWeight: FontWeight.w600),
      titleLarge: style(base.titleLarge, fontWeight: FontWeight.w700),
      titleMedium: style(base.titleMedium, fontWeight: FontWeight.w600),
      titleSmall: style(base.titleSmall, fontWeight: FontWeight.w600),
      bodyLarge: style(base.bodyLarge, height: 1.55),
      bodyMedium: style(base.bodyMedium, height: 1.5),
      bodySmall: style(base.bodySmall, height: 1.45),
      labelLarge: style(
        base.labelLarge,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
      labelMedium: style(base.labelMedium, fontWeight: FontWeight.w600),
      labelSmall: style(
        base.labelSmall,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }
}
