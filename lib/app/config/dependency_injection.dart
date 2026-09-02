import 'package:field_lens/app/config/app_config.dart';
import 'package:field_lens/app/config/database_module.dart';
import 'package:field_lens/app/config/feature_module.dart';
import 'package:field_lens/app/config/service_module.dart';
import 'package:field_lens/core/services/logger_service.dart';
import 'package:field_lens/features/settings/presentation/bloc/theme_cubit.dart';
import 'package:get_it/get_it.dart';

final GetIt sl = GetIt.instance;

/// Configures all application dependencies.
Future<void> configureDependencies() async {
  if (sl.isRegistered<LoggerService>()) {
    return;
  }

  sl
    ..registerLazySingleton<LoggerService>(LoggerService.new)
    ..registerLazySingleton<ThemeCubit>(ThemeCubit.new);

  registerDatabaseDependencies(sl);
  registerServiceDependencies();
  registerFeatureDependencies();

  if (AppConfig.enableLogging) {
    sl<LoggerService>().info('Dependencies configured');
  }
}
