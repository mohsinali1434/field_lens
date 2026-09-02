import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Manages application theme mode.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  void setThemeMode(ThemeMode mode) => emit(mode);

  void useSystem() => emit(ThemeMode.system);
  void useLight() => emit(ThemeMode.light);
  void useDark() => emit(ThemeMode.dark);
}
