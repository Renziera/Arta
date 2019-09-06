import 'package:Arta/dream_saving.dart';
import 'package:Arta/investasi.dart';
import 'package:Arta/virtual_account.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
                RaisedButton(
                  onPressed: () {
                    Fluttertoast.showToast(msg: 'Toko belum buka');
                  },
                  elevation: 6,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 8),
                      Image.asset('img/store.png', height: 56),
                      SizedBox(height: 8),
                      Text(
                        'Store',
                        style: TextStyle(fontSize: 10),
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                ),
                RaisedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => Investasi()));
                  },
                  elevation: 6,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 8),
                      Image.asset('img/investment.png', height: 56),
                      SizedBox(height: 8),
                      Text(
                        'Investasi',
                        style: TextStyle(fontSize: 10),
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                ),
                RaisedButton(
                  onPressed: () {
                    Fluttertoast.showToast(msg: 'Fitur belum tersedia');
                  },
                  elevation: 6,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 8),
                      Image.asset('img/mandate.png', height: 56),
                      SizedBox(height: 8),
                      Text(
                        'E-Mandate',
                        style: TextStyle(fontSize: 10),
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                RaisedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => VirtualAccount()));
                  },
                  elevation: 6,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 8),
                      Image.asset('img/virtual_account.png', height: 56),
                      SizedBox(height: 8),
                      Text(
                        'Virtual Account',
                        style: TextStyle(fontSize: 8),
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                ),
                RaisedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => DreamSaving()));
                  },
                  elevation: 6,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 8),
                      Image.asset('img/dream_saving.png', height: 56),
                      SizedBox(height: 8),
                      Text(
                        'Dream Saving',
                        style: TextStyle(fontSize: 8),
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                ),
                RaisedButton(
                  onPressed: () {
                    Fluttertoast.showToast(msg: 'Asuransi belum bekerja sama');
                  },
                  elevation: 6,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 8),
                      Image.asset('img/insurance.png', height: 56),
                      SizedBox(height: 8),
                      Text(
                        'Insurance',
                        style: TextStyle(fontSize: 10),
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Spesial Untukmu',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  Image.asset('img/promo1.png', height: 200),
                  Image.asset('img/promo2.png', height: 200),
                ],
              ),
            ),
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
