import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'dart:math' as math;
import '../config/env_config.dart';

class MapsService {
  static const LatLng indiaCenter = LatLng(20.5937, 78.9629);
  static const double initialZoom = 4;
  static const double routeZoom = 13;

  static CameraPosition get initialPosition =>
      CameraPosition(target: indiaCenter, zoom: initialZoom);

  /// Get polyline points between two locations
  static Future<List<LatLng>> getPolylinePoints({
    required LatLng start,
    required LatLng end,
  }) async {
    List<LatLng> polylineCoordinates = [];

    try {
      PolylinePoints polylinePoints = PolylinePoints();

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: EnvConfig.googleMapsApiKey,
        request: PolylineRequest(
          origin: PointLatLng(start.latitude, start.longitude),
          destination: PointLatLng(end.latitude, end.longitude),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      }
    } catch (e) {
      print("Error getting polyline points: $e");
    }

    return polylineCoordinates;
  }

  /// Get address from coordinates
  static Future<String?> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      List<geocoding.Placemark> placemarks = await geocoding
          .placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        return '${place.street}, ${place.locality}, ${place.administrativeArea}';
      }
    } catch (e) {
      print("Error getting address: $e");
    }
    return null;
  }

  /// Get coordinates from address
  static Future<LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      List<geocoding.Location> locations = await geocoding.locationFromAddress(
        address,
      );

      if (locations.isNotEmpty) {
        final location = locations[0];
        return LatLng(location.latitude, location.longitude);
      }
    } catch (e) {
      print("Error getting coordinates: $e");
    }
    return null;
  }

  /// Get current user location
  static Future<LatLng?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("Location service is disabled");
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print("Location permission denied");
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print("Location permission permanently denied");
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print("Error getting current location: $e");
      return null;
    }
  }

  /// Request location permission
  static Future<bool> requestLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("Location service is disabled");
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      print("Error requesting location permission: $e");
      return false;
    }
  }

  /// Calculate distance between two coordinates in kilometers
  static double calculateDistance({
    required LatLng start,
    required LatLng end,
  }) {
    const double earthRadius = 6371; // km

    final double dLat = _toRadian(end.latitude - start.latitude);
    final double dLng = _toRadian(end.longitude - start.longitude);
    final double a =
        (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        (math.cos(_toRadian(start.latitude)) *
            math.cos(_toRadian(end.latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2));
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  static double _toRadian(double degree) {
    return degree * math.pi / 180;
  }

  /// Get camera bounds for multiple locations
  static CameraPosition? getCameraPositionForBounds(List<LatLng> locations) {
    if (locations.isEmpty) return null;

    double minLat = locations[0].latitude;
    double maxLat = locations[0].latitude;
    double minLng = locations[0].longitude;
    double maxLng = locations[0].longitude;

    for (LatLng location in locations) {
      minLat = math.min(minLat, location.latitude);
      maxLat = math.max(maxLat, location.latitude);
      minLng = math.min(minLng, location.longitude);
      maxLng = math.max(maxLng, location.longitude);
    }

    final center = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);

    return CameraPosition(target: center, zoom: routeZoom);
  }

  /// Search for places by name
  static Future<List<geocoding.Location>> searchPlaces(String query) async {
    try {
      List<geocoding.Location> locations = await geocoding.locationFromAddress(
        query,
      );
      return locations;
    } catch (e) {
      print("Error searching places: $e");
      return [];
    }
  }
}
