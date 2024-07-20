
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyLogin extends StatefulWidget {
  const MyLogin({Key? key}) : super(key: key);

  @override
  State<MyLogin> createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  final TextEditingController aadhaarController = TextEditingController();
  final TextEditingController vehicleController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // List of valid users for testing (replace with your actual user data)
  final List<Map<String, String>> validUsers = [
    {
      'aadhaar': '123456789101',
      'vehicle': 'AB12AB1234',
      'mobile': '7569690754',
    },
    {
      'aadhaar': '276288662258',
      'vehicle': 'TS31H7308',
      'mobile': '9390501657',
    },
    {
      'aadhaar': '123456789013',
      'vehicle': 'KA01AB1235',
      'mobile': '9876543213',
    },
    {
      'aadhaar': '123456789014',
      'vehicle': 'KA01AB1236',
      'mobile': '9440377666',
    },
    {
      'aadhaar': '123476799014',
      'vehicle': 'KA41AB1636',
      'mobile': '9676545214',
    },
  ];

  // Function to verify phone number with Firebase Authentication
  Future<void> _verifyPhoneNumber(String phoneNumber) async {
    try {
      // Ensure the phone number is in E.164 format (replace '+91' with your country code)
      String formattedPhoneNumber = '+91' + phoneNumber;

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          _navigateToHomePage();
        },
        verificationFailed: (FirebaseAuthException e) {
          Fluttertoast.showToast(msg: 'Verification failed: ${e.message}');
          print('Verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          _showOTPDialog(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      print('Error verifying phone number: $e');
      Fluttertoast.showToast(msg: 'Error verifying phone number');
    }
  }

  // Function to show OTP dialog
  void _showOTPDialog(String verificationId) {
    TextEditingController otpController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Enter OTP'),
        content: TextField(
          controller: otpController,
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () async {
              String otp = otpController.text.trim();
              PhoneAuthCredential credential = PhoneAuthProvider.credential(
                verificationId: verificationId,
                smsCode: otp,
              );

              try {
                await _auth.signInWithCredential(credential);
                _navigateToHomePage();
              } catch (e) {
                Fluttertoast.showToast(msg: 'Invalid OTP. Please try again.');
                print('Invalid OTP: $e');
              }
            },
            child: Text('Verify'),
          ),
        ],
      ),
    );
  }

  // Function to navigate to home page
  void _navigateToHomePage() {
    Navigator.pushReplacementNamed(context, 'speedguard');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage('assets/register.png'), fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Container(
              padding: EdgeInsets.only(left: 35, top: 130),
              child: Text(
                'Welcome\nUser',
                style: TextStyle(color: Colors.white, fontSize: 33),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.5,
                  right: 35,
                  left: 35,
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: aadhaarController,
                      obscureText: true,
                      decoration: InputDecoration(
                        fillColor: Colors.grey.shade100,
                        filled: true,
                        hintText: 'Aadhaar Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    TextField(
                      controller: vehicleController,
                      decoration: InputDecoration(
                        fillColor: Colors.grey.shade100,
                        filled: true,
                        hintText: 'Registered vehicle No.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    TextField(
                      controller: mobileController,
                      keyboardType: TextInputType.phone, // Ensure numeric keyboard
                      decoration: InputDecoration(
                        fillColor: Colors.grey.shade100,
                        filled: true,
                        hintText: 'Registered mobile No.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Register',
                          style: TextStyle(
                            color: Color(0xff4c505b),
                            fontSize: 27,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Color(0xff4c505b),
                          child: IconButton(
                            color: Colors.white,
                            onPressed: () async {
                              String aadhaar = aadhaarController.text.trim();
                              String vehicle = vehicleController.text.trim();
                              String mobile = mobileController.text.trim();

                              if (aadhaar.isNotEmpty && vehicle.isNotEmpty && mobile.isNotEmpty) {
                                bool isValidUser = validUsers.any((user) =>
                                user['aadhaar'] == aadhaar &&
                                    user['vehicle'] == vehicle &&
                                    user['mobile'] == mobile,
                                );

                                if (isValidUser) {
                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  await prefs.setBool('isRegistered', true);
                                  await prefs.setString('vehicleNumber', vehicle);

                                  _verifyPhoneNumber(mobile);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Invalid user details')),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Please fill all fields')),
                                );
                              }
                            },
                            icon: Icon(Icons.arrow_forward),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

