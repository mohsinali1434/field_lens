import 'package:field_lens/app/app.dart';
import 'package:field_lens/app/config/dependency_injection.dart';
import 'package:field_lens/core/constants/setting_keys.dart';
import 'package:field_lens/core/demo/demo_data_seeder.dart';
import 'package:field_lens/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await configureDependencies();
  // Finish async startup work while the native splash is still visible.
  await Future.wait<void>(<Future<void>>[
    sl<SettingsRepository>().getSetting(SettingKeys.onboardingComplete),
    sl<DemoDataSeeder>().seedIfNeeded().then((_) {}),
  ]);

  runApp(const FieldLensApp());

  // Remove only after Flutter has painted the first real frames.
  widgetsBinding.addPostFrameCallback((_) {
    widgetsBinding.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
  });
}
