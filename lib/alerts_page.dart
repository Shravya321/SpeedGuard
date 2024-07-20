
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LogRecordsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log Records'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('speedLogs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No records found.'));
          }

          var logs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              var log = logs[index].data() as Map<String, dynamic>;

              String vehicleNumber = log['vehicleNumber'] ?? 'Unknown';
              double currentSpeed = (log['currentSpeed'] ?? 0.0).toDouble();
              int roadSpeed = log['roadSpeed'] ?? 0;
              String date = log['date'] ?? 'Unknown';
              String time = log['time'] ?? 'Unknown';
              double latitude = log['location']?['latitude'] ?? 0.0;
              double longitude = log['location']?['longitude'] ?? 0.0;

              return Card(
                margin: EdgeInsets.all(10.0),
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vehicle: $vehicleNumber'),
                      SizedBox(height: 5),
                      Text('Location: ($latitude, $longitude)'),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Your Speed: ${currentSpeed.round()} km/h'),
                          Text('Speed Limit: $roadSpeed km/h'),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('On: $date'),
                          Text('Time: $time'),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

