import 'package:arta/splash.dart';
import 'package:flutter/material.dart';

void main() => runApp(Arta());

class Arta extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arta',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
} 