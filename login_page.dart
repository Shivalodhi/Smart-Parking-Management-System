import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback toggleView;
  LoginScreen({required this.toggleView});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _inputController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> login() async {
    String input = _inputController.text.trim();
    String password = _passwordController.text.trim();

    try {
      UserCredential userCredential;
      if (isEmail(input)) {
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: input,
          password: password,
        );
      } else {
        String? email = await getEmailFromUsername(input);
        if (email != null) {
          userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('No user found with the given username.')));
          return;
        }
      }

      User? user = FirebaseAuth.instance.currentUser;
      await user?.reload();
      if (user != null && !user.emailVerified) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Please verify your email before logging in.')));
        FirebaseAuth.instance.signOut();
      } else {
        var pref = await SharedPreferences.getInstance();
        pref.setBool('isLogin', true);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed. ${e.toString()}')));
    }
  }

  Future<String?> getEmailFromUsername(String username) async {
    try {
      String sanitizedUsername = username.trim();
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: sanitizedUsername)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        return result.docs.first.get('email');
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  bool isEmail(String input) {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return regex.hasMatch(input);
  }

  Future<void> resetPassword() async {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Forgot Password'),
          content: TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: 'Enter registered email',
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String email = emailController.text.trim();

                try {
                  // Check if the email is registered with Firebase Authentication
                  List<String> signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);

                  if (signInMethods.isNotEmpty) {
                    // If the email is registered, send the password reset email
                    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                    Navigator.pop(context); // Close the dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Password reset email sent! Check your inbox.')),
                    );
                  } else {
                    // If the email is not registered, show a warning
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Email not found. Please register first.')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              },
              child: Text('Submit'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
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
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  SizedBox(height: 30),
                  TextField(
                    controller: _inputController,
                    decoration: InputDecoration(
                      labelText: 'Email or Username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: resetPassword, // Link to the reset password function
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline, // Makes the text look clickable
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: widget.toggleView,
                    child: Text(
                      'Don\'t have an account? Register here',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
