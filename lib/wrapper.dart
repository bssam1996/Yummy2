import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'UI/homepage.dart';
import 'models/user.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser?>(context);
    if (user == null) {
      return HomePageClass(customUser: null);
    } else {
      return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (!snapshot.hasData) {
                return HomePageClass(customUser: null);
              }
              var snapshowData = snapshot.data;
              if (snapshowData != null && snapshowData.exists) {
                user.role = (snapshot.data?.data() as Map)["Role"] ?? "";
                user.permissions =
                    (snapshot.data?.data() as Map)["Permissions"] ?? [];
              }
              return HomePageClass(customUser: user);
            },
      );
    }
  }
}
