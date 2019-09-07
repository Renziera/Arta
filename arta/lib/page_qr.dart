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
        String result = await dialogReceh(merchantDoc, nominal);
        if (result == null) {
          controller.resumeCamera();
          return;
        }

        if (result == 'sedekah') {
          String sedekah = await dialogSedekah();
          if (sedekah == null) {
            controller.resumeCamera();
            return;
          }
          batch.setData(
              userRef.collection('transaksi').document(transactionId), {
            'keterangan': 'Sedekah $sedekah',
            'nominal': nominal,
            'waktu': FieldValue.serverTimestamp(),
          });
        } else if (result == 'dream') {
          DocumentReference dream = await dialogImpian(user);
          if (dream == null) {
            controller.resumeCamera();
            return;
          }
          batch.updateData(dream, {'progress': FieldValue.increment(nominal)});
          batch.setData(
              userRef.collection('transaksi').document(transactionId), {
            'VA': false,
            'keterangan': 'Kembalian',
            'nominal': nominal,
            'merchant': merchantId,
            'waktu': FieldValue.serverTimestamp(),
          });
        } else if (result == 'investasi') {
          bool investasi = await dialogInvestasi(user);
          if (investasi == null) {
            controller.resumeCamera();
            return;
          }
          batch.updateData(userRef, {'emas': FieldValue.increment(nominal)});
          batch.setData(
              userRef.collection('transaksi').document(transactionId), {
            'keterangan': 'Investasi emas',
            'nominal': nominal,
            'waktu': FieldValue.serverTimestamp(),
          });
        } else {
          batch.updateData(userRef, {'saldo': FieldValue.increment(nominal)});
          batch.setData(
              userRef.collection('transaksi').document(transactionId), {
            'VA': false,
            'keterangan': 'Kembalian',
            'nominal': nominal,
            'merchant': merchantId,
            'waktu': FieldValue.serverTimestamp(),
          });
        }

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

  Future<DocumentReference> dialogImpian(FirebaseUser user) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Pilih target impianmu',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blue,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection('pengguna')
                  .document(user.uid)
                  .collection('dream')
                  .orderBy('waktu')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError)
                  return Center(child: Text('Error: ${snapshot.error}'));
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator());
                  default:
                    return ListView(
                      shrinkWrap: true,
                      children: snapshot.data.documents
                          .map((DocumentSnapshot document) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop(document.reference);
                          },
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    document.data['nama'],
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: LinearProgressIndicator(
                                      value: (document.data['progress'] /
                                          document.data['target']),
                                    ),
                                  ),
                                  Text(
                                      'Masih butuh Rp${formatUang((document.data['target'] - document.data['progress']).toString())} lagi'),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                }
              },
            ),
          );
        });
  }

  Future<bool> dialogInvestasi(FirebaseUser user) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Pilih target investasimu',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blue,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: ListTile(
              onTap: () {
                Navigator.of(context).pop(true);
              },
              title: Text(
                'Emas',
                style: TextStyle(color: Colors.blue, fontSize: 14),
              ),
              subtitle: StreamBuilder<DocumentSnapshot>(
                stream: Firestore.instance
                    .collection('pengguna')
                    .document(user.uid)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.connectionState != ConnectionState.waiting &&
                      !snapshot.hasError) {
                    return Text(
                      'Rp${formatUang(snapshot.data.data['emas']?.toString() ?? '0')}',
                      style: TextStyle(fontSize: 12),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
            ),
          );
        });
  }

  Future<String> dialogSedekah() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Pilih target sedekahmu',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blue,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: ListView(
              shrinkWrap: true,
              children: <Widget>[
                ListTile(
                  title: Text('Panti Asuhan X'),
                  subtitle: Text('Pembangunan gedung yang rusak'),
                  onTap: () {
                    Navigator.of(context).pop('Panti Asuhan X');
                  },
                ),
                ListTile(
                  title: Text('Masjid A'),
                  subtitle: Text('Perbaikan mimbar'),
                  onTap: () {
                    Navigator.of(context).pop('Masjid A');
                  },
                ),
                ListTile(
                  title: Text('Gereja B'),
                  subtitle: Text('Penambahan bilik pengakuan dosa'),
                  onTap: () {
                    Navigator.of(context).pop('Gereja B');
                  },
                ),
                ListTile(
                  title: Text('Vihara C'),
                  subtitle: Text('Pembangungan patung Dewi Kwan Im'),
                  onTap: () {
                    Navigator.of(context).pop('Vihara C');
                  },
                ),
              ],
            ),
          );
        });
  }

  Future<String> dialogReceh(DocumentSnapshot merchantDoc, int nominal) {
    return showDialog(
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
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                    'Anda mendapat kembalian dari ${merchantDoc.data['nama']} senilai Rp${formatUang(nominal.toString())}'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SizedBox(
                      width: 72,
                      child: RaisedButton(
                        onPressed: () {
                          Navigator.of(context).pop('sedekah');
                        },
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 4),
                            Image.asset('img/alms.png', height: 48),
                            Text(
                              'Sedekah',
                              style: TextStyle(fontSize: 8),
                            ),
                            SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 72,
                      child: RaisedButton(
                        onPressed: () {
                          Navigator.of(context).pop('dream');
                        },
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 4),
                            Image.asset('img/dream_saving.png', height: 48),
                            Text(
                              'Dream Saving',
                              style: TextStyle(fontSize: 6),
                            ),
                            SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 72,
                      child: RaisedButton(
                        onPressed: () {
                          Navigator.of(context).pop('investasi');
                        },
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 4),
                            Image.asset('img/investment.png', height: 48),
                            Text(
                              'Investasi',
                              style: TextStyle(fontSize: 8),
                            ),
                            SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                FlatButton(
                  child: Text(
                    'Masukkan ke ArtaWallet',
                    style: TextStyle(fontSize: 10),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop('arta');
                  },
                ),
              ],
            ),
          );
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
