//import 'package:flutter/services.dart';

import '/shared/snack.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
//import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:the_apple_sign_in/the_apple_sign_in.dart';
//import 'package:rxdart/rxdart.dart';
import '/models/user.dart';

const List<String> scopes = <String>[
  'https://www.googleapis.com/auth/contacts.readonly',
];

class AuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static Future<void>? _googleSignInInitialization;

  static Future<void> _initializeGoogleSignIn() {
    return _googleSignInInitialization ??= _googleSignIn.initialize();
  }

  /// Always check Google sign in initialization before use
  Future<void> _ensureGoogleSignInInitialized() async {
    try {
      await _initializeGoogleSignIn();
    } catch (e) {
      _googleSignInInitialization = null;
      print('Failed to initialize Google Sign-In: $e');
      rethrow;
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  // create user obj based on firebase user
  CustomUser? _userFromFirebaseUser(User? user) {
    return user != null
        ? CustomUser(
            uid: user.uid,
            email: user.email ?? "",
            username: user.displayName ?? "",
            role: "",
          )
        : null;
  }

  // auth change user stream
  Stream<CustomUser?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // sign in anon
  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      return _userFromFirebaseUser(user!);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  GoogleSignInAuthentication getAuthTokens(GoogleSignInAccount account) {
    // authentication is now synchronous
    return account.authentication;
  }

  Future<String?> getAccessTokenForScopes(List<String> scopes) async {
    await _ensureGoogleSignInInitialized();

    try {
      final authClient = _googleSignIn.authorizationClient;

      // Try to get existing authorization
      var authorization = await authClient.authorizationForScopes(scopes);

      // Request new authorization from user if needed.
      authorization ??= await authClient.authorizeScopes(scopes);

      return authorization.accessToken;
    } catch (error) {
      print('Failed to get access token for scopes: $error');
      return null;
    }
  }

  Future googlesigninfunction(GlobalKey<ScaffoldState> globalKey) async {
    try {
      final UserCredential result;

      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        googleProvider.setCustomParameters({'prompt': 'select_account'});
        result = await _auth.signInWithPopup(googleProvider);
      } else {
        await _ensureGoogleSignInInitialized();
        if (!_googleSignIn.supportsAuthenticate()) {
          throw FirebaseAuthException(
            code: 'unsupported-google-sign-in',
            message: 'Google sign-in is not supported by this platform flow.',
          );
        }

        final GoogleSignInAccount googleSignInAccount = await _googleSignIn
            .authenticate();
        final GoogleSignInAuthentication googleSignInAuthentication =
            googleSignInAccount.authentication;
        final String? idToken = googleSignInAuthentication.idToken;

        if (idToken == null) {
          throw FirebaseAuthException(
            code: 'missing-google-id-token',
            message: 'Google sign-in did not return an ID token.',
          );
        }

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: idToken,
        );
        result = await _auth.signInWithCredential(credential);
      }

      User? user = result.user;
      final firestoreInstance = FirebaseFirestore.instance;
      firestoreInstance.collection("Users").doc(user?.uid).set({
        "Name": user?.displayName,
        "Email": user?.email,
        "Date_Created": DateTime.now(),
      }, SetOptions(merge: true));
      return {"status": "success", "user": _userFromFirebaseUser(user)};
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(
        globalKey.currentContext!,
      ).showSnackBar(snack().displaySnackBar(e.toString()));
      // globalKey.currentState?.showSnackBar();
      return {"status": "error", "msg": e.toString()};
    }
  }

  // sign in with email and password
  Future signInWithEmailAndPassword(
    String email,
    String password,
    GlobalKey<ScaffoldState> globalKey,
  ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      User? user = result.user;
      final firestoreInstance = FirebaseFirestore.instance;
      firestoreInstance.collection("Users").doc(user?.uid).set({
        "Name": user?.displayName,
        "Email": user?.email,
        "Date_Created": DateTime.now(),
      }, SetOptions(merge: true));
      return {"status": "success", "user": _userFromFirebaseUser(user)};
    } catch (error) {
      print(error.toString());
      // ScaffoldMessenger.of(globalKey.currentContext!).showSnackBar(snack().displaySnackBar(error.toString()));
      // globalKey.currentState.showSnackBar(snack().displaySnackBar(error.toString()));
      return {"status": "error", "msg": error.toString()};
    }
  }

  // register with email and password
  Future registerWithEmailAndPassword(
    String? email,
    String? password,
    GlobalKey<ScaffoldState> globalKey,
  ) async {
    try {
      if (email == null || password == null) {
        return null;
      }
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      User? user = result.user;
      final firestoreInstance = FirebaseFirestore.instance;
      firestoreInstance.collection("Users").doc(user?.uid).set({
        "Name": user?.displayName,
        "Email": user?.email,
        "Date_Created": DateTime.now(),
      }, SetOptions(merge: true));
      return {"status": "success", "user": _userFromFirebaseUser(user)};
    } catch (error) {
      print(error.toString());
      // ScaffoldMessenger.of(globalKey.currentContext!).showSnackBar(snack().displaySnackBar(error.toString()));
      // globalKey.currentState.showSnackBar(snack().displaySnackBar(error.toString()));
      return {"status": "error", "msg": error.toString()};
    }
  }

  // sign out
  Future signOut() async {
    try {
      await _googleSignIn.disconnect();
    } catch (error) {
      print(error.toString());
    }
    try {
      return await _auth.signOut();
    } catch (error) {
      print(error.toString());
      return null;
    }
  }
}

final AuthService authService = AuthService();
