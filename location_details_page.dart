import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'view_url.dart';

class LocationDetailsPage extends StatefulWidget {
  final String locationName;
  final double latitude;
  final double longitude;

  LocationDetailsPage({
    required this.locationName,
    required this.latitude,
    required this.longitude,
  });

  @override
  _LocationDetailsPageState createState() => _LocationDetailsPageState();
}

class _LocationDetailsPageState extends State<LocationDetailsPage> {
  int availableSpaces = 0;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _fetchAvailableSpaces();
  }

  // Fetch the available parking spaces from Firebase
  void _fetchAvailableSpaces() {
    _database.child('parking/count').get().then((DataSnapshot snapshot) {
      if (snapshot.exists) {
        setState(() {
          availableSpaces = snapshot.value as int; // Update available spaces
        });
      }
    }).catchError((error) {
      print("Failed to fetch parking count: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.locationName),
      ),
      body: SingleChildScrollView( // Scrollable page
        child: Column(
          children: [
            // Google Map View in the top 30-40% of the screen
            SizedBox(
              
              height: MediaQuery.of(context).size.height * 0.35, // 35% of screen height
              child: const ViewUrl()
            ),
            SizedBox(height: 20),
            // Display available parking spaces
            Text(
              'Available Spaces: $availableSpaces',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Booking mechanism section (scrollable)
            Container(
              padding: EdgeInsets.all(16.0),
              color: Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Parking Booking',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Reserve your parking space now!',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Add booking logic here
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Booking feature coming soon!')),
                      );
                    },

                    child: Text('Book Now'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
