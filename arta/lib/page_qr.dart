import 'package:Arta/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRPage extends StatefulWidget {
  @override
  _QRPageState createState() => _QRPageState();
}

class _QRPageState extends State<QRPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController controller;

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (!scanData.contains('#')) return;
      controller.pauseCamera();
      var source = scanData.split('#');
      if (source.length != 4) {
        controller.resumeCamera();
        return;
      }
      bool pembayaran = source[0] == 'P';
      int nominal = int.parse(source[1]);
      String merchantId = source[2];
      String transactionId = source[3];
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      DocumentReference userRef =
          Firestore.instance.collection('pengguna').document(user.uid);
      DocumentReference merchantRef =
          Firestore.instance.collection('pengguna').document(merchantId);
      WriteBatch batch = Firestore.instance.batch();
      DocumentSnapshot merchantDoc = await merchantRef.get();
      if (pembayaran) {
        DocumentSnapshot ds = await userRef.get();
        if (ds.data['saldo'] < nominal) {
          Fluttertoast.showToast(msg: 'Saldo anda tidak cukup');
          controller.resumeCamera();
          return;
        }
        bool result = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text(
                    'Pembayaran senilai Rp${formatUang(nominal.toString())} ke ${merchantDoc.data['nama']}.'),
                actions: <Widget>[
                  RaisedButton(
                    color: Colors.blue,
                    textColor: Colors.white,
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              );
            });
        if (result ?? false) {
          batch.updateData(userRef, {'saldo': FieldValue.increment(-nominal)});
          batch.updateData(
              merchantRef, {'saldo': FieldValue.increment(nominal)});
          batch.setData(
              userRef.collection('transaksi').document(transactionId), {
            'VA': false,
            'keterangan': 'Pembayaran',
            'nominal': nominal,
            'merchant': merchantId,
            'waktu': FieldValue.serverTimestamp(),
          });
          batch.setData(
              merchantRef.collection('transaksi').document(transactionId), {
            'VA': false,
            'keterangan': 'Pembayaran',
            'nominal': nominal,
            'customer': user.uid,
            'waktu': FieldValue.serverTimestamp(),
          });
          await batch.commit();
          Fluttertoast.showToast(msg: 'Pembayaran berhasil');
        }
      } else {
        String result = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  'Receh',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                    'Anda mendapat kembalian dari ${merchantDoc.data['nama']} senilai Rp${formatUang(nominal.toString())}'),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop('sedekah');
                    },
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
                    onPressed: () {
                      Navigator.of(context).pop('dream');
                    },
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
                    onPressed: () {
                      Navigator.of(context).pop('investment');
                    },
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
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop('arta');
                    },
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
              );
            });
        batch.updateData(userRef, {'saldo': FieldValue.increment(nominal)});
        batch.setData(userRef.collection('transaksi').document(transactionId), {
          'VA': false,
          'keterangan': 'Kembalian',
          'nominal': nominal,
          'merchant': merchantId,
          'waktu': FieldValue.serverTimestamp(),
        });
        batch
            .updateData(merchantRef, {'saldo': FieldValue.increment(-nominal)});
        batch.setData(
            merchantRef.collection('transaksi').document(transactionId), {
          'VA': false,
          'keterangan': 'Kembalian',
          'nominal': nominal,
          'customer': user.uid,
          'waktu': FieldValue.serverTimestamp(),
        });
        await batch.commit();
      }
      controller.resumeCamera();
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
        ),
        Image.asset('img/crosshair.png'),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                RaisedButton(
                  onPressed: () => controller?.toggleFlash(),
                  child: Text('FLASH'),
                  color: Colors.blue,
                  textColor: Colors.white,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class QRSayaPage extends StatefulWidget {
  @override
  _QRSayaPageState createState() => _QRSayaPageState();
}

class _QRSayaPageState extends State<QRSayaPage> {
  String _id;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    setState(() {
      _id = user.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            'QR Saya',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          QrImage(
            data: _id ?? 'HMM',
            padding: EdgeInsets.all(36),
            embeddedImage: AssetImage('img/logo_arta.png'),
            embeddedImageStyle: QrEmbeddedImageStyle(size: Size.square(64)),
          ),
        ],
      ),
    );
  }
}
