import 'package:field_lens/core/constants/app_constants.dart';
import 'package:material_ui/material_ui.dart';

/// Shared animation durations and curves.
abstract final class AppAnimations {
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = AppConstants.animationDuration;
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration stagger = Duration(milliseconds: 45);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve entrance = Curves.easeOutBack;
  static const Curve exit = Curves.easeInCubic;
}
