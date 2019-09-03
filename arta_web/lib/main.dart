import 'dart:html' as html;
import 'package:flutter_web/material.dart';

void main() => runApp(ArtaWeb());

class ArtaWeb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arta',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Manjari',
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Arta',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Payment Simplified.',
              style: TextStyle(
                fontSize: 48,
              ),
            ),
            SizedBox(height: 36),
            RaisedButton(
              onPressed: () {
                html.window.location.href = "/apk";
              },
              child: Text(
                'Download Arta',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}
