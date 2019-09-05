import 'package:Arta/virtual_account.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
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
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => VirtualAccount()));
                  },
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
            SizedBox(height: 16),
            Image.asset('img/promo1.png'),
            Image.asset('img/promo2.png'),
            SizedBox(height: 16),
            Text(
              'Merchant Terdekat',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  Image.asset('img/merchant1.png'),
                  Image.asset('img/merchant2.png'),
                  Image.asset('img/merchant3.png'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
