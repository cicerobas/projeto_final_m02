import 'package:geolocator/geolocator.dart';

enum LocationIssue { serviceDisabled, permissionDenied, permissionDeniedForever, unavailable }

sealed class LocationResult {
  const LocationResult();
}

final class LocationAvailable extends LocationResult {
  final double latitude;
  final double longitude;

  const LocationAvailable({required this.latitude, required this.longitude});
}

final class LocationUnavailable extends LocationResult {
  final LocationIssue issue;

  const LocationUnavailable(this.issue);
}

abstract interface class LocationService {
  Future<LocationResult> getCurrentLocation();

  Future<void> openSettings(LocationIssue issue);
}

class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  static const _timeLimit = Duration(seconds: 10);

  @override
  Future<LocationResult> getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return const LocationUnavailable(LocationIssue.serviceDisabled);
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return const LocationUnavailable(LocationIssue.permissionDeniedForever);
    }
    if (permission == LocationPermission.denied) {
      return const LocationUnavailable(LocationIssue.permissionDenied);
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: _timeLimit),
      );
      return LocationAvailable(latitude: position.latitude, longitude: position.longitude);
    } catch (_) {
      final lastPosition = await Geolocator.getLastKnownPosition();
      return lastPosition == null
          ? const LocationUnavailable(LocationIssue.unavailable)
          : LocationAvailable(latitude: lastPosition.latitude, longitude: lastPosition.longitude);
    }
  }

  @override
  Future<void> openSettings(LocationIssue issue) => switch (issue) {
    LocationIssue.serviceDisabled => Geolocator.openLocationSettings(),
    _ => Geolocator.openAppSettings(),
  };
}
