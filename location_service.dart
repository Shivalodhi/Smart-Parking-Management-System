import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class LocationService {
  // Variables to store the current latitude and longitude
  double? currentLatitude;
  double? currentLongitude;

  // Request permission to access location
  Future<void> requestLocationPermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // If location services are not enabled, show a dialog to the user
      _showLocationServicesDialog(context);
      return Future.error('Location services are disabled.');
    }

    // Request location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  // Get current location and store it in the variables
  Future<void> getCurrentLocation(BuildContext context) async {
    await requestLocationPermission(context);

    try {
      // Fetch the current position
      Position position = await Geolocator.getCurrentPosition();

      // Store latitude and longitude in variables
      currentLatitude = position.latitude;
      currentLongitude = position.longitude;

      // You can print these values to verify
      print('Latitude: $currentLatitude, Longitude: $currentLongitude');
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  // Show a dialog to ask the user to enable location services
  void _showLocationServicesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enable Location Services'),
        content: Text(
            'Location services are disabled. Please enable them to continue.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Optionally, you can guide the user to the location settings
              Geolocator.openLocationSettings();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
