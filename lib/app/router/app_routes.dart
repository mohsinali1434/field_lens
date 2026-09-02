/// Route path constants for [GoRouter].
abstract final class AppRoutes {
  static const String home = '/';
  static const String inspections = '/inspections';
  static const String newInspection = '/inspections/new';
  static const String inspectionDetail = '/inspections/:id';
  static const String newObservation = '/inspections/:inspectionId/observations/new';
  static const String editObservation =
      '/inspections/:inspectionId/observations/:observationId/edit';
  static const String reports = '/reports';
  static const String search = '/search';
  static const String settings = '/settings';
  static const String onboarding = '/onboarding';
  static const String capturePhoto = '/inspections/:inspectionId/photo';
  static const String voiceNote = '/inspections/:inspectionId/voice';
  static const String inspectionNote = '/inspections/:inspectionId/notes';
  static const String inspectionLocation = '/inspections/:inspectionId/location';
  static const String signature = '/signature';

  static String inspectionDetailPath(String id) => '/inspections/$id';
  static String newObservationPath(String inspectionId) =>
      '/inspections/$inspectionId/observations/new';
  static String editObservationPath(
    String inspectionId,
    String observationId,
  ) =>
      '/inspections/$inspectionId/observations/$observationId/edit';
  static String capturePhotoPath(String inspectionId) =>
      '/inspections/$inspectionId/photo';
  static String voiceNotePath(String inspectionId) =>
      '/inspections/$inspectionId/voice';
  static String inspectionNotePath(String inspectionId) =>
      '/inspections/$inspectionId/notes';
  static String inspectionLocationPath(String inspectionId) =>
      '/inspections/$inspectionId/location';
}
