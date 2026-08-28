import 'package:flutter/material.dart';
import '/configurations/configurations.dart';
import 'models/contactus.dart';
class ContactPageClass extends StatelessWidget {
  const ContactPageClass({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contact Details"),
        centerTitle: true,
      ),
        backgroundColor: const Color(0xFF5F6EA8),
        body: Column(
          children: [
            Image.asset(
              'assets/icons/main.png',
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height/4.2,
            ),
            ContactUs(
              companyName: Configurations().globalAppName,
              phoneNumber: Configurations().globalPhoneNumber,
              tagLine: Configurations().globalDescription,
              facebookHandle: Configurations().facebookHandle,
              taglineColor: const Color(0xfff3f3f3),
              cardColor: Colors.indigo[200] as Color,
              email: "bssam2012@gmail.com",
              companyColor: Colors.indigo[200] as Color,
              textColor: Colors.white as Color,
            ),
          ],
        ),
    );
  }
}
