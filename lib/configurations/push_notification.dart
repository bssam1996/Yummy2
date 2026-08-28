import 'package:firebase_messaging/firebase_messaging.dart';
class PushNotificationsManager{
  PushNotificationsManager._();
  static final PushNotificationsManager _instance = PushNotificationsManager._();
  factory PushNotificationsManager() => _instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool _initialized = false;
  Future<void> init() async{
    if(!_initialized){
      //iOS
      _firebaseMessaging.requestPermission();
      //_firebaseMessaging.configure();
      String? token = await _firebaseMessaging.getToken();
      //print("Firebase Token is $token");
      _initialized = true;
    }
  }
}