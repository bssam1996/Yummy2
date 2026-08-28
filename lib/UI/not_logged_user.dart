import 'package:flutter/material.dart';
class NotLoggedUserHomeClass extends StatefulWidget {
  const NotLoggedUserHomeClass({Key? key}) : super(key: key);

  @override
  State<NotLoggedUserHomeClass> createState() => _NotLoggedUserHomeClassState();
}

class _NotLoggedUserHomeClassState extends State<NotLoggedUserHomeClass> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            child: Image.asset(
              'assets/icons/main.png',
              width: 512.0,
              height: 512.0,
            ),
            backgroundColor: Colors.transparent,
            radius: 30,
          ),
          Text("Welcome To Yummy!",
            style: TextStyle(
                color: Colors.indigo,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic
            ),)
        ],
      ),
    );
  }
}
