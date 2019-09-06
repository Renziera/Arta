import 'package:Arta/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Investasi extends StatefulWidget {
  @override
  _InvestasiState createState() => _InvestasiState();
}

class _InvestasiState extends State<Investasi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Investasi'),
      ),
      body: Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Image.asset(
                'img/emas.jpg',
                width: 128,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Emas',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Nilai emas anda'),
                  FutureBuilder<FirebaseUser>(
                    future: FirebaseAuth.instance.currentUser(),
                    builder: (BuildContext context,
                        AsyncSnapshot<FirebaseUser> snap) {
                      if (snap.connectionState == ConnectionState.done) {
                        return StreamBuilder<DocumentSnapshot>(
                          stream: Firestore.instance
                              .collection('pengguna')
                              .document(snap.data.uid)
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (snapshot.connectionState !=
                                    ConnectionState.waiting &&
                                !snapshot.hasError) {
                              return Text(
                                'Rp${formatUang(snapshot.data.data['emas']?.toString() ?? '0')}',
                                style: TextStyle(fontSize: 24),
                              );
                            }
                            return SizedBox.shrink();
                          },
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),
                  RaisedButton(
                    color: hijau,
                    textColor: Colors.white,
                    child: Text('Investasi'),
                    onPressed: () async {
                      String result = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Investasi Emas'),
                              content: TextField(
                                controller: TextEditingController(),
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    hintText: 'Nilai investasi'),
                                onSubmitted: (String s) {
                                  if (s.isEmpty || int.parse(s) <= 0) {
                                    Fluttertoast.showToast(
                                        msg: 'Tidak boleh kosong');
                                    return;
                                  }
                                  Navigator.of(context).pop(s);
                                },
                              ),
                            );
                          });

                      if (result == null) return;
                      int nominal = int.parse(result);
                      FirebaseUser user =
                          await FirebaseAuth.instance.currentUser();
                      DocumentSnapshot ds = await Firestore.instance
                          .collection('pengguna')
                          .document(user.uid)
                          .get();
                      if (ds.data['saldo'] < nominal) {
                        Fluttertoast.showToast(msg: 'Saldo tidak cukup');
                        return;
                      }
                      await ds.reference.updateData({
                        'emas': FieldValue.increment(nominal),
                        'saldo': FieldValue.increment(-nominal),
                      });
                      await ds.reference.collection('transaksi').add({
                        'keterangan': 'Investasi emas',
                        'nominal': nominal,
                        'waktu': FieldValue.serverTimestamp(),
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
