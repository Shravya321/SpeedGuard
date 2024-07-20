
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mini_project1/services/location_service.dart';
import 'package:mini_project1/services/openstreetmap_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mini_project1/services/twilio_service.dart'; // Import Twilio service
import 'package:intl/intl.dart'; // Import intl package for date formatting
import 'package:mini_project1/alerts_page.dart'; // Import LogRecordsPage
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _roadSpeed = 0;
  double _currentSpeed = 0.0;
  bool _isLoading = true;
  bool _isSpeedExceeded = false;
  final LocationService _locationService = LocationService();
  final OpenStreetMapService _openStreetMapService = OpenStreetMapService();
  final TwilioService _twilioService = TwilioService(); // Initialize Twilio service
  FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _fetchRoadSpeed();
    _startTrackingSpeed();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await _localNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _fetchRoadSpeed() async {
    try {
      final position = await _locationService.getCurrentLocation();
      print("Current Position: (${position.latitude}, ${position.longitude})");
      final speedLimit = await _openStreetMapService.getSpeedLimit(
        position.latitude,
        position.longitude,
      );
      print("Fetched Speed Limit: $speedLimit");

      if (speedLimit != null && speedLimit!=0) {
        setState(() {
          _roadSpeed = speedLimit;
          _isLoading = false;
        });
        _checkSpeedAndNotify(_currentSpeed, _roadSpeed);
      } else {
        print("No speed limit information available for the current road segment.");
      }
    } catch (e) {
      print("Error fetching the speed: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _checkSpeedAndNotify(double currentSpeed, int roadSpeed) async {
    if (roadSpeed!=0 && currentSpeed > (roadSpeed + 5)) {
      var notificationPermissionStatus = await Permission.notification.status;
      if (notificationPermissionStatus.isGranted) {
        _showNotification();
      } else if (notificationPermissionStatus.isDenied) {
        await Permission.notification.request();
      }
    }
    if (roadSpeed!=0 && currentSpeed > (roadSpeed + 10)) {
      _sendSpeedAlertSms(currentSpeed, roadSpeed);
    }
  }

  Future<void> _sendSpeedAlertSms(double currentSpeed, int roadSpeed) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? vehicleNumber = prefs.getString('vehicleNumber'); // Retrieve vehicle number
    if (vehicleNumber == null || vehicleNumber.isEmpty) {
      print('Vehicle number not found in SharedPreferences.');
      return;
    }

    // Format date and time in IST
    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now().toUtc().add(Duration(hours: 5, minutes: 30)));
    String formattedTime = DateFormat('HH:mm').format(DateTime.now().toUtc().add(Duration(hours: 5, minutes: 30)));

    // Construct message with vehicle number, speed limit, date, and time
    String message = '$vehicleNumber has exceeded the speed limit $roadSpeed km/h on $formattedDate at $formattedTime IST.';
    String recipient = '+919440377666  '; // Replace with the recipient phone number

    // Send SMS using Twilio service
    await _twilioService.sendSms(message, recipient);

    // Log data to Firestore
    final position = await _locationService.getCurrentLocation();
    await FirebaseFirestore.instance.collection('speedLogs').add({
      'vehicleNumber': vehicleNumber,
      'currentSpeed': currentSpeed,
      'roadSpeed': roadSpeed,
      'date': formattedDate,
      'time': formattedTime,
      'location': {
        'latitude': position.latitude,
        'longitude': position.longitude,
      },
    });

    print('Speed log saved to Firestore.');
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'speed_alerts',
      'Speed Alerts',
      channelDescription: 'Notification channel for speed alerts',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await _localNotificationsPlugin.show(
      0,
      'Speed Alert',
      'You are exceeding the speed limit by more than 5 km/h!',
      platformChannelSpecifics,
    );
  }

  void _startTrackingSpeed() {
    Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.high,
      distanceFilter: 1, // Update every 1 meter.
    ).listen((Position position) {
      if (position != null) {
        setState(() {
          _currentSpeed = position.speed * 3.6; // Convert m/s to km/h
          _isSpeedExceeded = _roadSpeed!=0 && _currentSpeed > (_roadSpeed + 5);
          if (_isSpeedExceeded) {
            _checkSpeedAndNotify(_currentSpeed, _roadSpeed);
          }
        });
        _fetchRoadSpeed();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isSpeedExceeded ? Colors.red : Colors.white,
      appBar: AppBar(
        title: Text('Speed Guard'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('isRegistered');
              // Navigate to the login page
              Navigator.pushReplacementNamed(context, 'login');
            },
          ),
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => LogRecordsPage()));
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Text(
                  'Speed Limit',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                CircularWidget(speed: _isLoading ? 0 : _roadSpeed),
              ],
            ),
            SizedBox(height: 50), // Spacer between the two circles
            Column(
              children: [
                CircularWidget(speed: _currentSpeed.toInt()),
                SizedBox(height: 10),
                Text(
                  'Your Speed',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CircularWidget extends StatelessWidget {
  final int speed;
  const CircularWidget({Key? key, required this.speed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.yellow, width: 6),
            ),
            child: Center(
              child: Text(
                '$speed',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            child: Text(
              'Kmph',
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}
