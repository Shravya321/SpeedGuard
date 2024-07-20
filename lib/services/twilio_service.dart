import 'package:twilio_flutter/twilio_flutter.dart';

class TwilioService {
  final TwilioFlutter _twilioFlutter = TwilioFlutter(
    accountSid: 'AC1e7cffd3711b041177f425989a1d1b45', // Replace with your Twilio Account SID
    authToken: 'c3683427181551df8015c21e83ce6c31', // Replace with your Twilio Auth Token
    twilioNumber: '+12077050658', // Replace with your Twilio Phone Number
  );

  Future<void> sendSms(String message, String recipient) async {
    await _twilioFlutter.sendSMS(
      toNumber: recipient,
      messageBody: message,
    );
  }
}

// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// class TwilioService {
//   final String accountSid = 'ACc3a210049fdd12b8ca6302caa7d95963';
//   final String authToken = 'df9d673e76dfa16ca8bd18a197fdc456';
//   final String fromPhoneNumber = '+16366370091';
//   final String toPhoneNumber = '7569690754';
//
//   Future<void> sendSms(String message) async {
//     final url = 'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json';
//     final response = await http.post(
//       Uri.parse(url),
//       headers: {
//         'Authorization': 'Basic ' + base64Encode(utf8.encode('$accountSid:$authToken')),
//         'Content-Type': 'application/x-www-form-urlencoded',
//       },
//       body: {
//         'From': fromPhoneNumber,
//         'To': toPhoneNumber,
//         'Body': message,
//       },
//     );
//
//     if (response.statusCode == 201) {
//       print('SMS sent successfully.');
//     } else {
//       print('Failed to send SMS: ${response.body}');
//     }
//   }
// }
