import 'package:field_lens/app/config/dependency_injection.dart';
import 'package:field_lens/app/config/feature_module.dart';
import 'package:field_lens/app/router/app_router.dart';
import 'package:field_lens/app/theme/app_theme.dart';
import 'package:field_lens/core/constants/app_constants.dart';
import 'package:field_lens/features/settings/presentation/bloc/theme_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// Root application widget.
class FieldLensApp extends StatelessWidget {
  const FieldLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeCubit>.value(
      value: sl<ThemeCubit>(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (BuildContext context, ThemeMode themeMode) {
          return AppBlocProviders(
            child: MaterialApp.router(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeMode,
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              // Bridges legacy SDK Material imports used by third-party packages
              // (e.g. go_router, flutter_bloc) during ecosystem migration.
              builder: (BuildContext context, Widget? child) {
                if (child == null) {
                  return const SizedBox.shrink();
                }
                return MaterialUiCompatibilityBridge(child: child);
              },
              routerConfig: AppRouter.router,
            ),
          );
        },
      ),
    );
  }
}
