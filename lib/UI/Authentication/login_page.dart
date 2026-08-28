//import 'package:avatar_glow/avatar_glow.dart';
//import 'package:auth_buttons/auth_buttons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'package:the_apple_sign_in/apple_sign_in_button.dart';
import '/Authentication/auth.dart';
import '/configurations/configurations.dart';
import 'package:flutter_login/flutter_login.dart';

//import 'package:animated_text_kit/animated_text_kit.dart';
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final AuthService _auth = AuthService();
  var customuser;
  final globalKey = GlobalKey<ScaffoldState>();
  Future<Map> _authUsergoogle() async {
    try {
      return await _auth.googlesigninfunction(globalKey);
    } catch (e) {
      print(e);
      return {"status": "error", "msg": e.toString()};
    }
  }

  Future<String>? _authUser(LoginData data) {
    return _auth
        .signInWithEmailAndPassword(data.name, data.password, globalKey)
        .then((value) {
          if (value["status"] == "error") {
            return value["msg"];
          } else {
            customuser = value['user'];
            return "";
          }
        });
  }

  Future<String>? _authUsersignup(SignupData data) {
    return _auth
        .registerWithEmailAndPassword(data.name, data.password, globalKey)
        .then((value) {
          if (value["status"] == "error") {
            return value["msg"];
          } else {
            customuser = value['user'];
            return "";
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      key: globalKey,
      backgroundColor: Color(0xFF316A6D),
      body: FlutterLogin(
        title: Configurations().globalAppName,
        logo: 'assets/icons/main.png',
        theme: LoginTheme(primaryColor: Color(0xFF204C6F)),
        hideForgotPasswordButton: true,
        onLogin: _authUser,
        onSignup: _authUsersignup,
        loginProviders: <LoginProvider>[
          LoginProvider(
            icon: FontAwesomeIcons.google,
            callback: () async {
              return _authUsergoogle().then((value) {
                if (value["status"] == "error") {
                  return value["msg"];
                } else {
                  customuser = value['user'];
                  return null;
                }
              });
            },
          ),
        ],
        onSubmitAnimationCompleted: () {
          if (customuser != null) {
            Navigator.pop(context);
          }
        },
        onRecoverPassword: (String recover) {
          print(recover);
        },
        //onRecoverPassword: _recoverPassword,
      ),
    );
  }
}
