import 'package:bloc_test/bloc_test.dart';
import 'package:field_lens/features/settings/presentation/bloc/theme_cubit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ThemeCubit', () {
    late ThemeCubit cubit;

    setUp(() => cubit = ThemeCubit());
    tearDown(() => cubit.close());

    test('initial state is system', () {
      expect(cubit.state, ThemeMode.system);
    });

    blocTest<ThemeCubit, ThemeMode>(
      'emits light when useLight is called',
      build: ThemeCubit.new,
      act: (ThemeCubit c) => c.useLight(),
      expect: () => <ThemeMode>[ThemeMode.light],
    );

    blocTest<ThemeCubit, ThemeMode>(
      'emits dark when useDark is called',
      build: ThemeCubit.new,
      act: (ThemeCubit c) => c.useDark(),
      expect: () => <ThemeMode>[ThemeMode.dark],
    );
  });
}
