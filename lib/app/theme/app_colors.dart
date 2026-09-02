import 'package:material_ui/material_ui.dart';

/// FieldLens color palette and semantic colors.
abstract final class AppColors {
  static const Color seed = Color(0xFF4F46E5);
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryDark = Color(0xFF3730A3);
  static const Color secondary = Color(0xFF6366F1);
  static const Color accent = Color(0xFF10B981);
  static const Color accentSoft = Color(0xFF34D399);

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  static const Color lightBackground = Color(0xFFF4F6FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color darkBackground = Color(0xFF0F1117);
  static const Color darkSurface = Color(0xFF1A1D27);

  static const Color neutral50 = Color(0xFFF8FAFC);
  static const Color neutral100 = Color(0xFFF1F5F9);
  static const Color neutral200 = Color(0xFFE2E8F0);
  static const Color neutral300 = Color(0xFFCBD5E1);
  static const Color neutral500 = Color(0xFF64748B);
  static const Color neutral700 = Color(0xFF334155);
  static const Color neutral900 = Color(0xFF0F172A);

  static const Color severityLow = Color(0xFF22C55E);
  static const Color severityMedium = Color(0xFFF59E0B);
  static const Color severityHigh = Color(0xFFF97316);
  static const Color severityCritical = Color(0xFFEF4444);

  static const LinearGradient heroGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFF4F46E5), Color(0xFF7C3AED)],
  );

  static const LinearGradient heroGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFF312E81), Color(0xFF4C1D95)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFF10B981), Color(0xFF06B6D4)],
  );
}
