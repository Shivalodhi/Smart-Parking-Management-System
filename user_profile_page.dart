import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfilePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('users').doc(_auth.currentUser?.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Handle error or no data cases
          if (snapshot.hasError) {
            return Center(child: Text('An error occurred.'));
          }

          if (!snapshot.hasData || snapshot.data == null || snapshot.data!.data() == null) {
            return Center(child: Text('No user data found.'));
          }

          // Safely cast the document data
          var userData = snapshot.data!.data() as Map<String, dynamic>;

          // Add email from FirebaseAuth
          String? email = _auth.currentUser?.email;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'User Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildProfileInfo('Full Name', userData['fullName'] ?? 'N/A'),
                    _buildProfileInfo('Username', userData['username'] ?? 'N/A'),
                    _buildProfileInfo('Age', userData['age']?.toString() ?? 'N/A'),
                    _buildProfileInfo('Email', email ?? 'N/A'),
                    _buildProfileInfo('Vehicle Number', userData['vehicleNumber'] ?? 'N/A'),
                    _buildProfileInfo('Vehicle Type', userData['vehicleType'] ?? 'N/A'),
                    _buildProfileInfo('Mobile Number', userData['mobile'] ?? 'N/A'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper method to display each profile info
  Widget _buildProfileInfo(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
