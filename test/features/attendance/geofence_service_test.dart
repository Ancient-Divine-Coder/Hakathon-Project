import 'package:campus_erp/core/services/geofence_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GeofenceService Tests', () {
    late GeofenceService service;

    setUp(() {
      service = GeofenceService();
      // Reset campus coordinates
      service.configureCampus(
        latitude: 26.9124,
        longitude: 75.7873,
        allowedRadius: 250.0,
        name: 'Turing Block',
      );
    });

    test('GeofenceService returns valid test coordinates in test runner', () async {
      final result = await service.verifyGeofence();

      expect(result.isInside, isTrue);
      expect(result.distanceMeters, lessThanOrEqualTo(250.0));
      expect(result.latitude, equals(26.9124));
      expect(result.longitude, equals(75.7873));
      expect(result.statusLabel, contains('Campus GPS & Wi-Fi Verified'));
      expect(result.formattedCoordinates, contains('26.9124° N, 75.7873° E'));
    });

    test('Haversine distance calculation is accurate', () {
      // Point 1: Campus center (26.9124, 75.7873)
      // Point 2: Slightly shifted north (~111 meters is ~0.001 deg lat)
      final distance = service.calculateHaversineDistance(
        lat1: 26.9124,
        lon1: 75.7873,
        lat2: 26.9134,
        lon2: 75.7873,
      );

      // Distance should be around 111 meters
      expect(distance, greaterThan(100.0));
      expect(distance, lessThan(120.0));
    });

    test('Telemetry map includes all required audit fields', () async {
      final result = await service.verifyGeofence();
      final map = result.toTelemetryMap();

      expect(map.containsKey('latitude'), isTrue);
      expect(map.containsKey('longitude'), isTrue);
      expect(map.containsKey('accuracyMeters'), isTrue);
      expect(map.containsKey('distanceMeters'), isTrue);
      expect(map.containsKey('isInsideGeofence'), isTrue);
      expect(map.containsKey('geofenceStatus'), isTrue);
      expect(map.containsKey('timestamp'), isTrue);
    });

    test('Configure campus modifies center and allows custom boundary', () {
      service.configureCampus(
        latitude: 28.6139,
        longitude: 77.2090,
        allowedRadius: 300.0,
        name: 'Aryabhata Research Wing',
      );

      expect(service.campusLatitude, equals(28.6139));
      expect(service.campusLongitude, equals(77.2090));
      expect(service.allowedRadiusMeters, equals(300.0));
      expect(service.campusName, equals('Aryabhata Research Wing'));
    });

    test('setCampusToCurrentLocation centers geofence with 100m radius', () async {
      final result = await service.setCampusToCurrentLocation(
        allowedRadius: 100.0,
        name: 'Current Location (100m)',
      );

      expect(service.allowedRadiusMeters, equals(100.0));
      expect(service.campusName, equals('Current Location (100m)'));
      expect(result.isInside, isTrue);
    });
  });
}
