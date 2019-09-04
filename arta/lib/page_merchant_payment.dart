import 'package:Arta/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MerchantPayment extends StatefulWidget {
  @override
  _MerchantPaymentState createState() => _MerchantPaymentState();
}

class _MerchantPaymentState extends State<MerchantPayment> {
  String nominal = '0';

  void keyPress(String value) {
    if (value == 'd') {
      if (nominal == '0') return;
      nominal = nominal.substring(0, nominal.length - 1);
      if (nominal.length == 0) nominal = '0';
      setState(() {});
      return;
    }

    if (nominal == '0') {
      if (value == '0' || value == '000') return;
      nominal = '';
    }

    setState(() {
      nominal += value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Pembayaran',
            style: TextStyle(fontSize: 24),
          ),
          Text(
            'Masukkan nominal yang harus dibayar',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            formatUangSpasi(nominal),
            overflow: TextOverflow.fade,
            softWrap: false,
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              FlatButton(
                child: Text(
                  '1',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                padding: EdgeInsets.all(24),
                onPressed: () => keyPress('1'),
              ),
              FlatButton(
                child: Text(
                  '2',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                padding: EdgeInsets.all(24),
                onPressed: () => keyPress('2'),
              ),
              FlatButton(
                child: Text(
                  '3',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                padding: EdgeInsets.all(24),
                onPressed: () => keyPress('3'),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              FlatButton(
                child: Text(
                  '4',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                padding: EdgeInsets.all(24),
                onPressed: () => keyPress('4'),
              ),
              FlatButton(
                child: Text(
                  '5',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                padding: EdgeInsets.all(24),
                onPressed: () => keyPress('5'),
              ),
              FlatButton(
                child: Text(
                  '6',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                padding: EdgeInsets.all(24),
                onPressed: () => keyPress('6'),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              FlatButton(
                child: Text(
                  '7',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                padding: EdgeInsets.all(24),
                onPressed: () => keyPress('7'),
              ),
              FlatButton(
                child: Text(
                  '8',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                padding: EdgeInsets.all(24),
                onPressed: () => keyPress('8'),
              ),
              FlatButton(
                child: Text(
                  '9',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                padding: EdgeInsets.all(24),
                onPressed: () => keyPress('9'),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              FlatButton(
                child: Text(
                  '000',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                padding: EdgeInsets.all(24),
                onPressed: () => keyPress('000'),
              ),
              FlatButton(
                child: Text(
                  '0',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                padding: EdgeInsets.all(24),
                onPressed: () => keyPress('0'),
              ),
              FlatButton(
                child: Icon(Icons.backspace),
                padding: EdgeInsets.all(24),
                onPressed: () => keyPress('d'),
              ),
            ],
          ),
          SizedBox(height: 16),
          RaisedButton(
            child: Text(
              'Tagih Pelanggan',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            color: Colors.blue,
            onPressed: () async {
              if (nominal == '0') return;
              FirebaseUser user = await FirebaseAuth.instance.currentUser();

              DocumentReference doc = Firestore.instance
                  .collection('pengguna')
                  .document(user.uid)
                  .collection('transaksi')
                  .document();

              var success = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    doc.snapshots().listen((ds) {
                      if (ds.exists) Navigator.of(context).pop(true);
                    });
                    return AlertDialog(
                      title: Text(
                        'Scan QR untuk pembayaran',
                        textAlign: TextAlign.center,
                      ),
                      content: SizedBox(
                        height: 256,
                        width: 256,
                        child: QrImage(
                          data: 'P#$nominal#${user.uid}#${doc.documentID}',
                        ),
                      ),
                    );
                  });

              if (success ?? false) {
                Fluttertoast.showToast(msg: 'Pembayaran berhasil');
                setState(() {
                  nominal = '0';
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
