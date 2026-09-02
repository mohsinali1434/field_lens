/// Application-wide constants.
abstract final class AppConstants {
  static const String appName = 'FieldLens';
  static const String appTagline = 'Capture · Organize · Analyze · Report';

  static const Duration searchDebounce = Duration(milliseconds: 350);
  static const Duration animationDuration = Duration(milliseconds: 250);

  static const double minTouchTarget = 48;
}
