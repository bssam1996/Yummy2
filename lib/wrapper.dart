import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'UI/homepage.dart';
import 'models/user.dart';
import 'dart:io';
class Wrapper extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser?>(context);
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    if (user == null){
      try{
        if(!kIsWeb) {
          firebaseMessaging.subscribeToTopic("General");
        }
      }catch(e){
        print("Error subscribing " +e.toString());
      }
      return HomePageClass(customUser:null);
    } else {
      return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('Users').doc(user.uid).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          try{
            if(!kIsWeb) {
              firebaseMessaging.subscribeToTopic("${user.uid}");
            }
          }catch(e){
            print("Error subscribing " +e.toString());
          }
          if (!snapshot.hasData) {
            return HomePageClass(customUser:null);
          }
          var snapshowData = snapshot.data;
          if(snapshowData != null && snapshowData.exists){
            //Get Role field and check its value
            try{
              if(!kIsWeb) {
                firebaseMessaging.subscribeToTopic("Admins");
              }
            }catch(e){
              print("Error subscribing " +e.toString());
            }
            user.role = (snapshot.data?.data() as Map)["Role"]??"";
            user.permissions = (snapshot.data?.data() as Map)["Permissions"]??[];
          }
          return HomePageClass(customUser:user);
        },
      );
    }
  }
}
