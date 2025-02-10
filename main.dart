import 'dart:async';  // For Timer functionality
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';  // For Firebase initialization
import 'package:smart_parking/firebase_options.dart';  // Your Firebase options
import 'login_page.dart';
import 'registration_page.dart';
import 'home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';


// Main function to initialize Firebase
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

// Root of the application
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Parking',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo, // Main theme color
            textStyle: TextStyle(fontSize: 18),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.indigo, // Main theme color for TextButtons
          ),
        ),
      ),

      home: SplashScreen(), // Start with the splash screen
      debugShowCheckedModeBanner: false, // Remove debug banner
      routes: {
        '/login': (context) => AuthScreen(),  // Add your login page
        '/home': (context) => HomePage(),  // Add your home page
      },
    );
  }
}

// Splash Screen widget
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  // Separate asynchronous method to check login status
  void checkLoginStatus() async {
    var pref = await SharedPreferences.getInstance();
    var check = pref.getBool('isLogin') ?? false;

    Future.delayed(Duration(seconds: 4), () {
      if (check) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AuthScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splash_background.jpg'),  // Path to your image
            fit: BoxFit.cover,  // Maintain aspect ratio and cover the full screen
          ),
        ),
        child: Container(
          color: Colors.black54, // Optional: Adds a semi-transparent overlay for better text visibility
          child: Center(
            child: Text(
              'Welcome to Smart Parking App',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.black45,
                    offset: Offset(2, 2),
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


// Authentication screen with login and registration options
class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;  // Toggle between login and registration

  // Toggle between Login and Registration screen
  void toggleView() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(isLogin ? 'Login' : 'Register')),
      ),
      body: isLogin
          ? LoginScreen(toggleView: toggleView)
          : RegisterScreen(toggleView: toggleView),
    );
  }
}
