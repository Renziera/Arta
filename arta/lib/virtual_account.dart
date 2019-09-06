import 'package:Arta/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class VirtualAccount extends StatefulWidget {
  @override
  _VirtualAccountState createState() => _VirtualAccountState();
}

class _VirtualAccountState extends State<VirtualAccount> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Virtual Account'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String result = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Buat VA'),
                  content: TextField(
                    controller: TextEditingController(),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(hintText: 'Nominal VA'),
                    onSubmitted: (String s) {
                      if (s.isEmpty || int.parse(s) <= 0) {
                        Fluttertoast.showToast(
                            msg: 'Nominal tidak boleh kosong');
                        return;
                      }
                      Navigator.of(context).pop(s);
                    },
                  ),
                );
              });

          if (result == null) return;
          int nominal = int.parse(result);
          FirebaseUser user = await FirebaseAuth.instance.currentUser();
          DocumentSnapshot ds = await Firestore.instance
              .collection('pengguna')
              .document(user.uid)
              .get();
          if (ds.data['saldo'] < nominal) {
            Fluttertoast.showToast(msg: 'Saldo tidak cukup');
            return;
          }
          await ds.reference
              .updateData({'saldo': FieldValue.increment(-nominal)});
          await ds.reference.collection('VA').add({
            'nominal': nominal,
            'waktu': FieldValue.serverTimestamp(),
          });
        },
        child: Icon(Icons.add),
      ),
      body: FutureBuilder<FirebaseUser>(
        future: FirebaseAuth.instance.currentUser(),
        builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection('pengguna')
                  .document(snapshot.data.uid)
                  .collection('VA')
                  .orderBy('waktu', descending: true)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> querySnapshot) {
                if (querySnapshot.hasError)
                  return Center(child: Text('Terjadi Kesalahan'));
                switch (querySnapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  default:
                    return ListView(
                      children: querySnapshot.data.documents
                          .map((DocumentSnapshot document) {
                        return ListTile(
                          title: Text(
                              'Rp${formatUang(document.data['nominal'].toString())}'),
                          subtitle: Text(document.documentID),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => BayarVA(
                                  docRef: document.reference,
                                  userRef: Firestore.instance
                                      .collection('pengguna')
                                      .document(snapshot.data.uid),
                                ),
                              ),
                            );
                          },
                          onLongPress: () async {
                            await Firestore.instance
                                .collection('pengguna')
                                .document(snapshot.data.uid)
                                .updateData({
                              'saldo':
                                  FieldValue.increment(document.data['nominal'])
                            });
                            await document.reference.delete();
                          },
                        );
                      }).toList(),
                    );
                }
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class BayarVA extends StatefulWidget {
  final DocumentReference docRef;
  final DocumentReference userRef;
  const BayarVA({@required this.docRef, @required this.userRef});
  @override
  _BayarVAState createState() => _BayarVAState();
}

class _BayarVAState extends State<BayarVA> {
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
      if (source[0] != 'P') {
        Fluttertoast.showToast(msg: 'Bukan pembayaran');
        controller.resumeCamera();
        return;
      }
      int nominal = int.parse(source[1]);
      String merchantId = source[2];
      String transactionId = source[3];

      DocumentSnapshot ds = await widget.docRef.get();
      if (ds.data['nominal'] < nominal) {
        Fluttertoast.showToast(msg: 'Saldo anda tidak cukup');
        controller.resumeCamera();
        return;
      }
      DocumentReference merchantRef =
          Firestore.instance.collection('pengguna').document(merchantId);
      DocumentSnapshot merchantDoc = await merchantRef.get();
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
        WriteBatch batch = Firestore.instance.batch();
        batch.updateData(
            widget.docRef, {'nominal': FieldValue.increment(-nominal)});
        batch.updateData(merchantRef, {'saldo': FieldValue.increment(nominal)});
        batch.setData(
              widget.userRef.collection('transaksi').document(transactionId), {
            'VA': true,
            'keterangan': 'Pembayaran (VA)',
            'nominal': nominal,
            'merchant': merchantId,
            'waktu': FieldValue.serverTimestamp(),
          });
          batch.setData(
              merchantRef.collection('transaksi').document(transactionId), {
            'VA': true,
            'keterangan': 'Pembayaran (VA)',
            'nominal': nominal,
            'waktu': FieldValue.serverTimestamp(),
          });
        await batch.commit();
        Fluttertoast.showToast(msg: 'Pembayaran berhasil');
        Navigator.of(context).pop();
        return;
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Pembayaran VA'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: widget.docRef.get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              alignment: Alignment.center,
              children: <Widget>[
                QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                ),
                Image.asset('img/crosshair.png'),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Rp${formatUang(snapshot.data['nominal'].toString())}',
                      style: TextStyle(color: Colors.white, fontSize: 48),
                    ),
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
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
