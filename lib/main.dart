import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import '/wrapper.dart';
import 'Authentication/auth.dart';
import 'models/user.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'shared/constants.dart';

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
    final colorScheme = ColorScheme.fromSeed(
      seedColor: darkBlue,
      primary: darkBlue,
      secondary: purpleColor,
      surface: Colors.white,
      brightness: Brightness.light,
    );
    return StreamProvider<CustomUser?>.value(
      value: AuthService().user,
      initialData: null,
      child: MaterialApp(
        title: "Yummy 2",
        debugShowCheckedModeBanner: false,
        color: darkBlue,
        locale: Locale('en'),
        home: Wrapper(),
        builder: EasyLoading.init(),
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: colorScheme,
          scaffoldBackgroundColor: lightBlue,
          appBarTheme: const AppBarTheme(
            backgroundColor: darkBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFF0E1D5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: darkBlue, width: 2),
            ),
            labelStyle: const TextStyle(color: darkBlue),
          ),
          dividerTheme: const DividerThemeData(color: Color(0xFFF0E1D5)),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: purpleColor,
            foregroundColor: Colors.white,
            shape: StadiumBorder(),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: darkBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
