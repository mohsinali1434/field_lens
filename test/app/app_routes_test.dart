import 'package:field_lens/app/router/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppRoutes', () {
    test('builds inspection detail path', () {
      expect(
        AppRoutes.inspectionDetailPath('abc-123'),
        '/inspections/abc-123',
      );
    });

    test('builds observation form path', () {
      expect(
        AppRoutes.newObservationPath('insp-1'),
        '/inspections/insp-1/observations/new',
      );
    });

    test('builds media and note paths', () {
      expect(
        AppRoutes.capturePhotoPath('insp-1'),
        '/inspections/insp-1/photo',
      );
      expect(
        AppRoutes.voiceNotePath('insp-1'),
        '/inspections/insp-1/voice',
      );
      expect(
        AppRoutes.inspectionNotePath('insp-1'),
        '/inspections/insp-1/notes',
      );
      expect(
        AppRoutes.inspectionLocationPath('insp-1'),
        '/inspections/insp-1/location',
      );
    });

    test('defines shell route constants', () {
      expect(AppRoutes.home, '/');
      expect(AppRoutes.inspections, '/inspections');
      expect(AppRoutes.reports, '/reports');
      expect(AppRoutes.search, '/search');
      expect(AppRoutes.settings, '/settings');
      expect(AppRoutes.onboarding, '/onboarding');
    });
  });
}
