import 'package:Arta/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MerchantWallet extends StatefulWidget {
  @override
  _MerchantWalletState createState() => _MerchantWalletState();
}

class _MerchantWalletState extends State<MerchantWallet> {
  String saldo;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    Firestore.instance
        .collection('pengguna')
        .document(user.uid)
        .snapshots()
        .listen((ds) {
      setState(() {
        saldo = ds.data['saldo'].toString();
        saldo = formatUang(saldo);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          Text(
            'Wallet Anda',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Card(
            margin: EdgeInsets.symmetric(horizontal: 24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Arta',
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                  Text(
                    'Rp${saldo ?? '0'}',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.symmetric(horizontal: 24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'GoPay',
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                  Text(
                    'Rp150.000',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.symmetric(horizontal: 24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'OVO',
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                  Text(
                    'Rp250.000',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FlatButton(
              child: Text('+ Tambah Wallet'),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
