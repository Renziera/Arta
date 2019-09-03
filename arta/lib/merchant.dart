import 'package:Arta/page_merchant_payment.dart';
import 'package:Arta/page_merchant_receh.dart';
import 'package:Arta/page_merchant_transaksi.dart';
import 'package:Arta/page_merchant_wallet.dart';
import 'package:Arta/splash.dart';
import 'package:Arta/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MerchantScreen extends StatefulWidget {
  @override
  _MerchantScreenState createState() => _MerchantScreenState();
}

class _MerchantScreenState extends State<MerchantScreen> {
  String nama;
  String saldo;
  int _currentIndex = 0;
  List<Widget> pages;

  @override
  void initState() {
    super.initState();
    fetchData();
    pages = [
      MerchantPayment(),
      MerchantReceh(),
      MerchantTransaksi(),
      MerchantWallet(),
    ];
  }

  void fetchData() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    Firestore.instance
        .collection('pengguna')
        .document(user.uid)
        .snapshots()
        .listen((ds) {
      setState(() {
        nama = ds.data['nama'];
        saldo = ds.data['saldo'].toString();
        saldo = formatUang(saldo);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          nama ?? '',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: pages[_currentIndex],
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Arta Merchant',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    nama ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Rp${saldo ?? ''}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Payment'),
              leading: Icon(Icons.payment),
              selected: _currentIndex == 0,
              onTap: () {
                setState(() {
                  _currentIndex = 0;
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text('Receh'),
              leading: Icon(Icons.monetization_on),
              selected: _currentIndex == 1,
              onTap: () {
                setState(() {
                  _currentIndex = 1;
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text('Transaksi'),
              leading: Icon(Icons.history),
              selected: _currentIndex == 2,
              onTap: () {
                setState(() {
                  _currentIndex = 2;
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text('Wallet'),
              leading: Icon(Icons.account_balance_wallet),
              selected: _currentIndex == 3,
              onTap: () {
                setState(() {
                  _currentIndex = 3;
                });
                Navigator.of(context).pop();
              },
            ),
            Divider(color: Colors.black),
            ListTile(
              title: Text('Keluar'),
              leading: Icon(Icons.exit_to_app),
              selected: _currentIndex == 3,
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => SplashScreen()),
                    (r) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
