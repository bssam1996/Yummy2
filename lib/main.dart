import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import '/wrapper.dart';
import 'Authentication/auth.dart';
import 'models/user.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyC3hgLAnqHADuJa3ZnkgM4bLi_ZI_-LhO4",
        authDomain: "yummy2-recipes.firebaseapp.com",
        appId: "1:245149410158:web:a1d521aba0894ab274d77f",
        messagingSenderId: "245149410158",
        projectId: "yummy2-recipes",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<CustomUser?>.value(
      value: AuthService().user,
      initialData: null,
      child: MaterialApp(
        title: "Yummy 2",
        debugShowCheckedModeBanner: false,
        color: Color(0xFF303A5D),
        locale: Locale('en'),
        home: Wrapper(),
        builder: EasyLoading.init(),
        theme: ThemeData(primaryColor: Color(0xFF303A5D)),
      ),
    );
  }
}
