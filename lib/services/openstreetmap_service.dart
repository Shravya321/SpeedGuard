import 'package:http/http.dart' as http;
import 'dart:convert';

class OpenStreetMapService {
  Future<int> getSpeedLimit(double latitude, double longitude) async {
    final url = 'https://overpass-api.de/api/interpreter?data=[out:json];way(around:200,$latitude,$longitude)[maxspeed];out;';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('API Response: $data'); // Log the full response

        // Assuming the speed limit is in the 'elements' list in the response
        if (data['elements'] != null && data['elements'].isNotEmpty) {
          final speedLimit = data['elements'][0]['tags']['maxspeed'];
          return int.tryParse(speedLimit) ?? 0;
        } else {
          print('No speed limit found in the API response.');
        }
      } else {
        print('Error: Received status code ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching speed limit: $e');
    }
    return 0;
  }
}

// class OpenStreetMapService {
//   Future<int> getSpeedLimit(double latitude, double longitude) async {
//     // Encode latitude and longitude
//     String formattedLatitude = latitude.toString();
//     String formattedLongitude = longitude.toString();
//
//     // Construct URL with encoded coordinates
//     String overpassUrl = 'https://overpass-api.de/api/interpreter?data=[out:json];way(around:10, $formattedLatitude, $formattedLongitude)[maxspeed];out;';
//
//     final response = await http.get(Uri.parse(overpassUrl));
//     if (response.statusCode == 200) {
//       var data = json.decode(response.body);
//       if (data['elements'] != null && data['elements'].isNotEmpty) {
//         var speedLimit = data['elements'][0]['tags']['maxspeed'];
//         return int.tryParse(speedLimit) ?? 0;
//       } else {
//         return 0; // No speed limit found
//       }
//     } else {
//       throw Exception('Failed to load speed limit');
//     }
//   }
// }
