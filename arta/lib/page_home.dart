import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            FlatButton(
              onPressed: () {},
              child: Column(
                children: <Widget>[
                  Image.asset('img/alms.png'),
                  Text(
                    'Alms',
                    style: TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
            FlatButton(
              onPressed: () {},
              child: Column(
                children: <Widget>[
                  Image.asset('img/dream_saving.png'),
                  Text(
                    'Dream Saving',
                    style: TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
            FlatButton(
              onPressed: () {},
              child: Column(
                children: <Widget>[
                  Image.asset('img/investment.png'),
                  Text(
                    'Investment',
                    style: TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            FlatButton(
              onPressed: () {},
              child: Column(
                children: <Widget>[
                  Image.asset('img/alms.png'),
                  Text(
                    'Virtual Account',
                    style: TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
            FlatButton(
              onPressed: () {},
              child: Column(
                children: <Widget>[
                  Image.asset('img/dream_saving.png'),
                  Text(
                    'E-Mandate',
                    style: TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
            FlatButton(
              onPressed: () {},
              child: Column(
                children: <Widget>[
                  Image.asset('img/investment.png'),
                  Text(
                    'Insurance',
                    style: TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
