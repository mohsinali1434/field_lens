import 'package:field_lens/app/theme/app_theme_extension.dart';
import 'package:material_ui/material_ui.dart';

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  AppThemeExtension get appTheme =>
      theme.extension<AppThemeExtension>()!;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  bool get isTablet => screenSize.shortestSide >= 600;
}
