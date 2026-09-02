import 'package:material_ui/material_ui.dart';

/// Elevation and shadow styles.
abstract final class AppShadows {
  static List<BoxShadow> card(Color shadowColor) => <BoxShadow>[
    BoxShadow(
      color: shadowColor.withValues(alpha: 0.06),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: shadowColor.withValues(alpha: 0.03),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> elevated(Color shadowColor) => <BoxShadow>[
    BoxShadow(
      color: shadowColor.withValues(alpha: 0.1),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
    BoxShadow(
      color: shadowColor.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> glow(Color color) => <BoxShadow>[
    BoxShadow(
      color: color.withValues(alpha: 0.35),
      blurRadius: 24,
      spreadRadius: -4,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> navBar(Color shadowColor) => <BoxShadow>[
    BoxShadow(
      color: shadowColor.withValues(alpha: 0.12),
      blurRadius: 24,
      offset: const Offset(0, -4),
    ),
  ];
}
