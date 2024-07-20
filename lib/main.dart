
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:mini_project1/speedguard.dart';
// import 'package:mini_project1/login.dart';
//
// void main() {
//   runApp(MaterialApp(
//     debugShowCheckedModeBanner: false,
//     home: CheckRegistration(), // Use CheckRegistration as the home
//     routes: {
//       'login': (context) => MyLogin(),
//       'speedguard': (context) => HomePage(),
//     },
//   ));
// }
//
// class CheckRegistration extends StatefulWidget {
//   @override
//   _CheckRegistrationState createState() => _CheckRegistrationState();
// }
//
// class _CheckRegistrationState extends State<CheckRegistration> {
//   bool isRegistered = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _checkIfRegistered();
//   }
//
//   _checkIfRegistered() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool registered = prefs.getBool('isRegistered') ?? false;
//     setState(() {
//       isRegistered = registered;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return isRegistered ? HomePage() : MyLogin();
//   }
// }

// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:mini_project1/speedguard.dart';
// import 'package:mini_project1/login.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(MaterialApp(
//     debugShowCheckedModeBanner: false,
//     home: CheckRegistration(), // Use CheckRegistration as the home
//     routes: {
//       'login': (context) => MyLogin(),
//       'speedguard': (context) => HomePage(),
//     },
//   ));
// }
//
// class CheckRegistration extends StatefulWidget {
//   @override
//   _CheckRegistrationState createState() => _CheckRegistrationState();
// }
//
// class _CheckRegistrationState extends State<CheckRegistration> {
//   bool isRegistered = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _checkIfRegistered();
//   }
//
//   _checkIfRegistered() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool registered = prefs.getBool('isRegistered') ?? false;
//     setState(() {
//       isRegistered = registered;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return isRegistered ? HomePage() : MyLogin();
//   }
// }
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mini_project1/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mini_project1/speedguard.dart';
import 'package:mini_project1/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CheckRegistration(),
      routes: {
        'login': (context) => MyLogin(),
        'speedguard': (context) => HomePage(),
      },
    );
  }
}

class CheckRegistration extends StatefulWidget {
  @override
  _CheckRegistrationState createState() => _CheckRegistrationState();
}

class _CheckRegistrationState extends State<CheckRegistration> {
  bool isRegistered = false;

  @override
  void initState() {
    super.initState();
    _checkIfRegistered();
  }

  _checkIfRegistered() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool registered = prefs.getBool('isRegistered') ?? false;
    setState(() {
      isRegistered = registered;
    });

    if (isRegistered) {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? currentUser = auth.currentUser;
      if (currentUser != null) {
        Navigator.pushReplacementNamed(context, 'speedguard');
      } else {
        Navigator.pushReplacementNamed(context, 'login');
      }
    } else {
      Navigator.pushReplacementNamed(context, 'login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:mini_project1/firebase_options.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:mini_project1/speedguard.dart';
// import 'package:mini_project1/login.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: CheckRegistration(), // Use CheckRegistration as the home
//       routes: {
//         'login': (context) => MyLogin(),
//         'speedguard': (context) => HomePage(),
//       },
//     );
//   }
// }
//
// class CheckRegistration extends StatefulWidget {
//   @override
//   _CheckRegistrationState createState() => _CheckRegistrationState();
// }
//
// class _CheckRegistrationState extends State<CheckRegistration> {
//   bool isRegistered = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _checkIfRegistered();
//   }
//
//   _checkIfRegistered() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool registered = prefs.getBool('isRegistered') ?? false;
//     setState(() {
//       isRegistered = registered;
//     });
//
//     if (isRegistered) {
//       // Check if the user is authenticated with Firebase
//       FirebaseAuth auth = FirebaseAuth.instance;
//       User? currentUser = auth.currentUser;
//       if (currentUser != null) {
//         // Navigate to homepage if authenticated
//         Navigator.pushReplacementNamed(context, 'speedguard');
//       } else {
//         // Navigate to login page if not authenticated
//         Navigator.pushReplacementNamed(context, 'login');
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return isRegistered ? HomePage() : MyLogin();
//   }
// }
