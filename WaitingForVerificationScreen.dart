import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class WaitingForVerificationScreen extends StatefulWidget {
  final String userId;
  WaitingForVerificationScreen(this.userId);

  @override
  _WaitingForVerificationScreenState createState() => _WaitingForVerificationScreenState();
}

class _WaitingForVerificationScreenState extends State<WaitingForVerificationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      checkEmailVerified();
    });
  }

  Future<void> checkEmailVerified() async {
    User? user = _auth.currentUser;
    await user?.reload(); // Reload user data
    if (user != null && user.emailVerified) {
      // If email verified, move data to permanent Firestore collection
      await moveToPermanentStorage(widget.userId);

      // Navigate to login screen
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => AuthScreen()));
    } else {
      // Retry checking after some delay
      Future.delayed(Duration(seconds: 5), () {
        checkEmailVerified();
      });
    }
  }

  Future<void> moveToPermanentStorage(String userId) async {
    // Get temporary user data
    final DocumentSnapshot tempUserData = await FirebaseFirestore.instance
        .collection('pending_users').doc(userId).get();

    if (tempUserData.exists) {
      // Cast the data to Map<String, dynamic> before saving
      final Map<String, dynamic>? data = tempUserData.data() as Map<
          String,
          dynamic>?;

      if (data != null) {
        // Move data to permanent storage
        await FirebaseFirestore.instance.collection('users').doc(userId).set(
            data);
        // Delete from temporary storage
        await FirebaseFirestore.instance.collection('pending_users')
            .doc(userId)
            .delete();
      } else {
        print("Error: No data found for the user.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Your Email'),
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Please check your email for a verification link. This link is only valid for 10 minutes.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight
                  .bold), // Emphasize the 10-minute validity
            ),
            SizedBox(height: 10),
            Text(
              'Make sure to verify your email before the link expires.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
