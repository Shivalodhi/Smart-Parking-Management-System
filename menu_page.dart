import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart'; // Ensure this is present
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'user_profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MenuPage extends StatefulWidget {


  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  File? _image; // To store the selected image
  String userName = "User Name"; // Placeholder for user name
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchUserName(); // Fetch the user's name when the widget is initialized
  }
  Future<void> _fetchUserName() async {
    try {
      // Get the current user's UID from FirebaseAuth
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Access Firestore and get the user's document by UID
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid) // Assuming user documents are identified by UID
            .get();

        // Check if the document exists and has a 'name' field
        if (userDoc.exists && userDoc['fullName'] != null) {
          setState(() {
            userName = userDoc['fullName']; // Set the fetched name
          });
        } else {
          setState(() {
            userName = "No Name Found"; // If name field is not present
          });
        }
      }
    } catch (e) {
      print("Error fetching user name: $e");
      setState(() {
        userName = "Error"; // Display error if fetching fails
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blueAccent,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: _chooseImage, // Change profile picture on tap
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: _image == null
                      ? AssetImage('assets/images/default_pic.png') // Default image
                      : FileImage(_image!) as ImageProvider, // Display selected image
                  child: _image == null
                      ? Icon(Icons.person, size: 30, color: Colors.white) // Placeholder icon
                      : null,
                ),
              ),
              SizedBox(width: 15),
              Text(
                userName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        ListTile(
          leading: Icon(Icons.person),
          title: Text('User Profile'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserProfilePage()), // Navigate to UserProfilePage
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.info),
          title: Text('About Us'),
          onTap: () {
            Navigator.pop(context); // Close the drawer
            _showAboutDialog(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.logout),
          title: Text('Logout'),
          onTap: () {
            _showLogoutConfirmationDialog(context);
          },
        ),
      ],
    );
  }

  // Method to choose image from gallery
  Future<void> _chooseImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Set the selected image
      });
    }
  }

  // Method to remove image
  void _removeImage() {
    setState(() {
      _image = null; // Set image to null to remove it
    });
  }

  // Method to show about dialog
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('About Us'),
        content: Text('This app is designed to help users find nearby parking locations.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  // Method to show logout confirmation dialog
  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout Confirmation'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              var pref = await SharedPreferences.getInstance();
              pref.setBool('isLogin', false);
              FirebaseAuth.instance.signOut().then((_) {
                Navigator.of(context).pop(); // Close the confirmation dialog
                Navigator.of(context).pushReplacementNamed('/login'); // Navigate to the login screen
              }).catchError((error) {
                print("Logout failed: $error");
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Logout failed. Please try again."),
                ));
              });
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
