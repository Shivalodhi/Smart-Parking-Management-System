import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_parking/WaitingForVerificationScreen.dart';


class RegisterScreen extends StatefulWidget {
  final VoidCallback toggleView;

  RegisterScreen({required this.toggleView});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>(); // Key to track form validation

  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();
  final _mobileController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  String _vehicleType = 'bike';

 // bool _isOtpSent = false; // Track whether OTP has been sent
 // final TextEditingController _otpController = TextEditingController();
 // final OTPVerification otpVerification = OTPVerification();

  // void _sendOtp() {
  //   otpVerification.sendOtp(_mobileController.text);
  //   setState(() {
  //     _isOtpSent = true; // Set the OTP sent state
  //   });
  // }

  // void _verifyOtp() {
  //   if (otpVerification.verifyOtp(_otpController.text)) {
  //     showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         content: Text('Number verification done'),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               // Disable the OTP input and button
  //               setState(() {
  //                 _isOtpSent = false; // Reset state
  //               });
  //             },
  //             child: Text('OK'),
  //           ),
  //         ],
  //       ),
  //     );
  //     // Freeze the OTP input and button (you can further implement UI for this)
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid OTP. Please try again.')));
  //   }
  // }

  late Timer _timer;
  late DateTime _registrationTime;

  Future<void> register() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        await userCredential.user?.sendEmailVerification();

        await storeTemporaryData(userCredential.user!.uid);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WaitingForVerificationScreen(userCredential.user!.uid)),
        );
      } on FirebaseAuthException catch (e) {
        print("Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.message}")));
      }
    }
  }

  Future<void> storeTemporaryData(String userId) async {
    final CollectionReference usersCollection = FirebaseFirestore.instance.collection('pending_users');

    await usersCollection.doc(userId).set({
      'username': _usernameController.text,
      'fullName': _fullNameController.text,
      'age': _ageController.text,
      'mobile': _mobileController.text,
      'vehicleNumber': _vehicleNumberController.text,
      'vehicleType': _vehicleType,
      'registrationTime': DateTime.now().toIso8601String(),
      'status': 'pending',
    });
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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    SizedBox(height: 30),
                    _buildTextField('Username', _usernameController),
                    SizedBox(height: 15),
                    _buildTextField('Full Name', _fullNameController),
                    SizedBox(height: 15),
                    _buildTextField('Age', _ageController, isAge: true),
                    SizedBox(height: 15),
                    _buildTextField('Mobile Number', _mobileController, isPhone: true),

                    // SizedBox(height: 15),
                    // SizedBox(height: 15),
                    // ElevatedButton(
                    //   onPressed: _sendOtp,
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Colors.green, // Change to your desired color
                    //     foregroundColor: Colors.white, // Change text color if needed
                    //   ),
                    //   child: Text('Send OTP'),
                    // ),
                    // SizedBox(height: 15),
                    // if (_isOtpSent) ...[
                    //   _buildTextField('Enter OTP', _otpController),
                    //   ElevatedButton(
                    //     onPressed: _verifyOtp,
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: Colors.green, // Change to your desired color
                    //       foregroundColor: Colors.white, // Change text color if needed
                    //     ),
                    //     child: Text('Verify OTP'),
                    //   ),
                    // ],


                    SizedBox(height: 15),
                    _buildTextField('Vehicle Number', _vehicleNumberController, isVehicle: true),
                    SizedBox(height: 15),
                    _buildTextField('Email', _emailController, isEmail: true),
                    SizedBox(height: 15),
                    _buildTextField('Password', _passwordController, obscureText: true, isPassword: true),
                    SizedBox(height: 20),
                    Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choose your vehicle type',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700], // Matching the theme with the rest of the form
                            ),
                          ),
                          SizedBox(height: 15),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10), // Rounded corners
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 5), // Slight elevation effect
                                ),
                              ],
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                            child: DropdownButtonFormField<String>(
                              value: _vehicleType,
                              decoration: InputDecoration.collapsed(hintText: ''),
                              dropdownColor: Colors.white,
                              style: TextStyle(color: Colors.black, fontSize: 16),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _vehicleType = newValue!;
                                });
                              },
                              items: <String>['bike', 'car', 'truck'].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              icon: Icon(Icons.arrow_drop_down, color: Colors.green), // Arrow color
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                      child: Text(
                        'Register',
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
                        'Already have an account? Login here',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


// Input validation
  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false, bool isEmail = false, bool isPhone = false, bool isPassword = false, bool isAge = false, bool isVehicle = false}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText, // Add obscureText here
      keyboardType: isPhone ? TextInputType.phone : isEmail ? TextInputType.emailAddress : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        if (isPhone && !RegExp(r'^[0-9]{10}$').hasMatch(value)) {
          return 'Please enter a valid 10-digit phone number';
        }
        if (isAge) {
          int? age = int.tryParse(value);
          if (age == null || age > 100) {
            return 'Please enter a valid age (10-100)';
          }
        }
        if (isPassword && value.length < 8) {
          return 'Password must be at least 8 characters';
        }
        if (isVehicle && !RegExp(r'^[A-Z]{2}\s?[0-9]{2}\s?[A-Z]{1,2}\s?[0-9]{4}$').hasMatch(value)) {
          return 'Please enter a valid vehicle number (e.g., AB12CD3456)';
        }
        return null;
      },
    );
  }
}
