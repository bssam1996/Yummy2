import 'package:cloud_firestore/cloud_firestore.dart';
Future<Map?> getUserData(String userID) async {
  try {
    return await FirebaseFirestore.instance.collection("Users").doc(userID).get().then((value) {
      if (value.exists) {
        return value.data();
      } else {
        return {};
      }
    });
  }catch(error){
    print(error);
    return {};
  }
}