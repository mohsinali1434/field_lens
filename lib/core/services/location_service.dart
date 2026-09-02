import 'package:field_lens/core/errors/failures.dart';
import 'package:field_lens/core/utils/result.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Captures device location for inspections and observations.
class LocationService {
  Future<Result<bool>> requestPermission() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      return const Success<bool>(true);
    }
    return const Error<bool>(
      PermissionFailure(message: 'Location permission denied'),
    );
  }

  Future<Result<({double latitude, double longitude})>> getCurrentLocation() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        return const Error<({double latitude, double longitude})>(
          LocationFailure(message: 'Location services are disabled'),
        );
      }

      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied ||
            requested == LocationPermission.deniedForever) {
          return const Error<({double latitude, double longitude})>(
            PermissionFailure(message: 'Location permission denied'),
          );
        }
      }

      final position = await Geolocator.getCurrentPosition();
      return Success<({double latitude, double longitude})>(
        (latitude: position.latitude, longitude: position.longitude),
      );
    } on Object catch (error) {
      return Error<({double latitude, double longitude})>(
        LocationFailure(message: 'Failed to get location: $error'),
      );
    }
  }
}
