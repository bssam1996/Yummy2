import 'package:flutter/material.dart';
import '../shared/constants.dart';

class NotLoggedUserHomeClass extends StatefulWidget {
  const NotLoggedUserHomeClass({Key? key}) : super(key: key);

  @override
  State<NotLoggedUserHomeClass> createState() => _NotLoggedUserHomeClassState();
}

class _NotLoggedUserHomeClassState extends State<NotLoggedUserHomeClass> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            const SizedBox(height: 18),
            const Text(
              "Welcome to Yummy",
              style: TextStyle(
                color: darkBlue,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sign in to save, organise, and share your favourite recipes.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B), height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
