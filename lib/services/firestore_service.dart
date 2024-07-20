// // import 'package:cloud_firestore/cloud_firestore.dart';
// //
// // class FirestoreService {
// //   final FirebaseFirestore _db = FirebaseFirestore.instance;
// //
// //   Future<void> logSpeedAlert(String userId, double currentSpeed, int roadSpeed) {
// //     return _db.collection('speed_alerts').add({
// //       'userId': userId,
// //       'currentSpeed': currentSpeed,
// //       'roadSpeed': roadSpeed,
// //       'timestamp': FieldValue.serverTimestamp(),
// //     });
// //   }
// // }
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class FirebaseService {
//   // Singleton instance
//   static final FirebaseService _instance = FirebaseService._internal();
//
//   factory FirebaseService() => _instance;
//
//   FirebaseService._internal();
//
//   // Initialize Firebase App
//   Future<void> initialize() async {
//     await Firebase.initializeApp();
//     print('Firebase initialized');
//   }
//
//   // Firebase Auth instance
//   FirebaseAuth get auth => FirebaseAuth.instance;
//
//   // Firestore instance
//   FirebaseFirestore get firestore => FirebaseFirestore.instance;
//
// // Other Firebase services can be added here as needed
// }
