import 'package:field_lens/app/router/app_page_transitions.dart';
import 'package:field_lens/app/router/app_routes.dart';
import 'package:field_lens/core/constants/setting_keys.dart';
import 'package:field_lens/core/widgets/navigation_shell.dart';
import 'package:field_lens/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:field_lens/features/inspections/presentation/pages/create_inspection_page.dart';
import 'package:field_lens/features/inspections/presentation/pages/inspection_detail_page.dart';
import 'package:field_lens/features/inspections/presentation/pages/inspections_page.dart';
import 'package:field_lens/features/inspections/presentation/pages/location_map_page.dart';
import 'package:field_lens/features/inspections/presentation/pages/note_form_page.dart';
import 'package:field_lens/features/media/presentation/pages/capture_photo_page.dart';
import 'package:field_lens/features/media/presentation/pages/voice_note_page.dart';
import 'package:field_lens/features/observations/presentation/pages/observation_form_page.dart';
import 'package:field_lens/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:field_lens/features/reports/presentation/pages/reports_page.dart';
import 'package:field_lens/features/reports/presentation/pages/signature_page.dart';
import 'package:field_lens/features/search/presentation/pages/search_page.dart';
import 'package:field_lens/features/settings/domain/repositories/settings_repository.dart';
import 'package:field_lens/features/settings/presentation/pages/settings_page.dart';
import 'package:field_lens/app/config/dependency_injection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

/// Application router configuration.
abstract final class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.home,
    redirect: (BuildContext context, GoRouterState state) async {
      if (state.matchedLocation == AppRoutes.onboarding) {
        return null;
      }

      final settings = await sl<SettingsRepository>().getSetting(
        SettingKeys.onboardingComplete,
      );
      final completed = settings.valueOrNull?.value == 'true';
      if (!completed) {
        return AppRoutes.onboarding;
      }
      return null;
    },
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) {
          return NavigationShell(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                builder: (BuildContext context, GoRouterState state) {
                  return const DashboardPage();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.inspections,
                name: 'inspections',
                builder: (BuildContext context, GoRouterState state) {
                  return const InspectionsPage();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.reports,
                name: 'reports',
                builder: (BuildContext context, GoRouterState state) {
                  return const ReportsPage();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.search,
                name: 'search',
                builder: (BuildContext context, GoRouterState state) {
                  return const SearchPage();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.settings,
                name: 'settings',
                builder: (BuildContext context, GoRouterState state) {
                  return const SettingsPage();
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.newInspection,
        parentNavigatorKey: rootNavigatorKey,
        name: 'newInspection',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return AppPageTransitions.fadeSlide(
            key: state.pageKey,
            child: const CreateInspectionPage(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.inspectionDetail,
        parentNavigatorKey: rootNavigatorKey,
        name: 'inspectionDetail',
        pageBuilder: (BuildContext context, GoRouterState state) {
          final id = state.pathParameters['id']!;
          return AppPageTransitions.fadeSlide(
            key: state.pageKey,
            child: InspectionDetailPage(inspectionId: id),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.newObservation,
        parentNavigatorKey: rootNavigatorKey,
        name: 'newObservation',
        pageBuilder: (BuildContext context, GoRouterState state) {
          final inspectionId = state.pathParameters['inspectionId']!;
          return AppPageTransitions.fadeSlide(
            key: state.pageKey,
            child: ObservationFormPage(inspectionId: inspectionId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.editObservation,
        parentNavigatorKey: rootNavigatorKey,
        name: 'editObservation',
        pageBuilder: (BuildContext context, GoRouterState state) {
          final inspectionId = state.pathParameters['inspectionId']!;
          final observationId = state.pathParameters['observationId']!;
          return AppPageTransitions.fadeSlide(
            key: state.pageKey,
            child: ObservationFormPage(
              inspectionId: inspectionId,
              observationId: observationId,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        parentNavigatorKey: rootNavigatorKey,
        name: 'onboarding',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return AppPageTransitions.scaleFade(
            key: state.pageKey,
            child: const OnboardingPage(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.capturePhoto,
        parentNavigatorKey: rootNavigatorKey,
        name: 'capturePhoto',
        pageBuilder: (BuildContext context, GoRouterState state) {
          final inspectionId = state.pathParameters['inspectionId']!;
          return AppPageTransitions.scaleFade(
            key: state.pageKey,
            child: CapturePhotoPage(inspectionId: inspectionId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.voiceNote,
        parentNavigatorKey: rootNavigatorKey,
        name: 'voiceNote',
        pageBuilder: (BuildContext context, GoRouterState state) {
          final inspectionId = state.pathParameters['inspectionId']!;
          return AppPageTransitions.scaleFade(
            key: state.pageKey,
            child: VoiceNotePage(inspectionId: inspectionId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.inspectionNote,
        parentNavigatorKey: rootNavigatorKey,
        name: 'inspectionNote',
        pageBuilder: (BuildContext context, GoRouterState state) {
          final inspectionId = state.pathParameters['inspectionId']!;
          return AppPageTransitions.fadeSlide(
            key: state.pageKey,
            child: NoteFormPage(inspectionId: inspectionId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.inspectionLocation,
        parentNavigatorKey: rootNavigatorKey,
        name: 'inspectionLocation',
        pageBuilder: (BuildContext context, GoRouterState state) {
          final inspectionId = state.pathParameters['inspectionId']!;
          return AppPageTransitions.fadeSlide(
            key: state.pageKey,
            child: LocationMapPage(inspectionId: inspectionId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.signature,
        parentNavigatorKey: rootNavigatorKey,
        name: 'signature',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return AppPageTransitions.scaleFade(
            key: state.pageKey,
            child: const SignaturePage(),
          );
        },
      ),
    ],
  );
}
