import 'package:Arta/home.dart';
import 'package:Arta/login.dart';
import 'package:Arta/merchant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  void start(BuildContext context) async {
    await Future.delayed(Duration(milliseconds: 500));
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user == null) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()));
      return;
    }
    DocumentSnapshot ds = await Firestore.instance
        .collection('pengguna')
        .document(user.uid)
        .get();

    if (!ds.exists) {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()));
      return;
    }

    if (ds.data['merchant'] ?? false) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MerchantScreen()));
    } else {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    start(context);
    return Scaffold(
      body: Center(
        child: Text('INI SPLASH'),
      ),
    );
  }
}
