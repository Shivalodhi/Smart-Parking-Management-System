import 'package:flutter/material.dart';
import 'location_details_page.dart';
import 'menu_page.dart';
import 'location_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> parkingLocations = [
    {'name': 'New Market Parking', 'lat': 23.233, 'long': 77.412},
    {'name': 'Roshanpura Parking', 'lat': 23.245, 'long': 77.423},
    {'name': 'MP Nagar Parking', 'lat': 23.259, 'long': 77.431},
    {'name': 'Sample 5', 'lat': 23.233, 'long': 77.412},
    {'name': 'Sample 6', 'lat': 23.233, 'long': 77.412},
    {'name': 'Sample 7', 'lat': 23.233, 'long': 77.412},
    {'name': 'Sample 8', 'lat': 23.233, 'long': 77.412},
    {'name': 'Sample 9', 'lat': 23.233, 'long': 77.412},
    {'name': 'Sample 10', 'lat': 23.233, 'long': 77.412},
    {'name': 'Sample 11', 'lat': 23.233, 'long': 77.412},
    {'name': 'Sample 12', 'lat': 23.233, 'long': 77.412},
    {'name': 'Sample 13', 'lat': 23.233, 'long': 77.412},
    {'name': 'Sample 14', 'lat': 23.233, 'long': 77.412},
    {'name': 'Sample 15', 'lat': 23.233, 'long': 77.412},
    {'name': 'Sample 16', 'lat': 23.233, 'long': 77.412},
    {'name': 'Sample 17', 'lat': 23.233, 'long': 77.412},
  ];

  // Define a LocationService instance
  LocationService locationService = LocationService();

  @override
  void initState() {
    super.initState();
    // Request location permission as soon as the home page is opened
    locationService.getCurrentLocation(context).catchError((error) {
      print('Error requesting location permission: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Center(child: Text('Nearby Parking Locations')),
      ),
      body: ListView.builder(
        itemCount: parkingLocations.length,
        itemBuilder: (context, index) {
          final location = parkingLocations[index];
          return Card(
            color: Colors.white70,
            margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0), // Add margin around the card
            child: ListTile(
              title: Text(location['name']),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocationDetailsPage(
                      locationName: location['name'],
                      latitude: location['lat'],
                      longitude: location['long'],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      drawer: Drawer(
        child: MenuPage(),
      ),
    );
  }
}
