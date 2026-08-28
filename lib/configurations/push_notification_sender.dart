// Replace with server token from firebase console settings.
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import '/configurations/configurations.dart';

final String serverToken = Configurations().pushServer;
final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
Future<void> sendAndRetrieveMessage(String uid,String title,String body) async {
  await firebaseMessaging.requestPermission(
    sound: true, badge: true, alert: true, provisional: false,
  );
  await http.post(
    Uri.parse('https://fcm.googleapis.com/fcm/send'),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverToken',
    },
    body: jsonEncode(
      <String, dynamic>{
        'notification': <String, dynamic>{
          'body': body,
          'title': title
        },
        'priority': 'high',
        'data': <String, dynamic>{
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'status': 'done'
        },
        'to': '/topics/$uid',
      },
    ),
  );
}
// Future<Map<String, dynamic>> sendAndRetrieveMessage(String uid,String title,String body) async {
//   await firebaseMessaging.requestPermission(
//     sound: true, badge: true, alert: true, provisional: false,
//   );
//   await http.post(
//     Uri.parse('https://fcm.googleapis.com/fcm/send'),
//     headers: <String, String>{
//       'Content-Type': 'application/json',
//       'Authorization': 'key=$serverToken',
//     },
//     body: jsonEncode(
//       <String, dynamic>{
//         'notification': <String, dynamic>{
//           'body': body,
//           'title': title
//         },
//         'priority': 'high',
//         'data': <String, dynamic>{
//           'click_action': 'FLUTTER_NOTIFICATION_CLICK',
//           'status': 'done'
//         },
//         'to': '/topics/$uid',
//       },
//     ),
//   );
//   final Completer<Map<String, dynamic>> completer =
//   Completer<Map<String, dynamic>>();
//   firebaseMessaging.configure(
//     onMessage: (Map<String, dynamic> message) async {
//       completer.complete(message);
//     },
//   );
//
//   return completer.future;
// }