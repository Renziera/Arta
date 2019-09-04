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
      if (pembayaran) {
        DocumentSnapshot ds = await userRef.get();
        if (ds.data['saldo'] < nominal) {
          Fluttertoast.showToast(msg: 'Saldo anda tidak cukup');
          controller.resumeCamera();
          return;
        }
        DocumentSnapshot merchantDoc = await merchantRef.get();
        await showDialog(
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
                      batch.updateData(
                          userRef, {'saldo': FieldValue.increment(-nominal)});
                      batch.updateData(merchantRef,
                          {'saldo': FieldValue.increment(nominal)});
                      batch.setData(
                          userRef
                              .collection('transaksi')
                              .document(transactionId),
                          {
                            'VA': false,
                            'pembayaran': true,
                            'nominal': nominal,
                            'merchant': merchantId,
                            'waktu': FieldValue.serverTimestamp(),
                          });
                      batch.setData(
                          merchantRef
                              .collection('transaksi')
                              .document(transactionId),
                          {
                            'VA': false,
                            'pembayaran': true,
                            'nominal': nominal,
                            'customer': user.uid,
                            'waktu': FieldValue.serverTimestamp(),
                          });
                    },
                  ),
                ],
              );
            });
      } else {
        batch.updateData(userRef, {'saldo': FieldValue.increment(nominal)});
        batch
            .updateData(merchantRef, {'saldo': FieldValue.increment(-nominal)});
        batch.setData(userRef.collection('transaksi').document(transactionId), {
          'VA': false,
          'pembayaran': false,
          'nominal': nominal,
          'merchant': merchantId,
          'waktu': FieldValue.serverTimestamp(),
        });
        batch.setData(
            merchantRef.collection('transaksi').document(transactionId), {
          'VA': false,
          'pembayaran': false,
          'nominal': nominal,
          'customer': user.uid,
          'waktu': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      if (!pembayaran)
        Fluttertoast.showToast(
            msg: 'Mendapat kembalian Rp${formatUang(nominal.toString())}');
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
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            RaisedButton(
              onPressed: () => controller?.toggleFlash(),
              child: Text('FLASH'),
              color: Colors.blue,
              textColor: Colors.white,
            ),
            RaisedButton(
              onPressed: () async {
                FirebaseUser user = await FirebaseAuth.instance.currentUser();
                controller.pauseCamera();
                await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          'QR Saya',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: SizedBox(
                          height: 256,
                          width: 256,
                          child: QrImage(
                            data: '${user.uid}',
                          ),
                        ),
                      );
                    });
                controller.resumeCamera();
              },
              child: Text('QR Saya'),
              color: Colors.blue,
              textColor: Colors.white,
            ),
          ],
        ),
      ],
    );
  }
}
