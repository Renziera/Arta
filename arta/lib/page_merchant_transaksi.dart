import 'package:Arta/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MerchantTransaksi extends StatefulWidget {
  @override
  _MerchantTransaksiState createState() => _MerchantTransaksiState();
}

class _MerchantTransaksiState extends State<MerchantTransaksi> {
  List<DocumentSnapshot> _list = [];

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
        .collection('transaksi')
        .orderBy('waktu', descending: true)
        .snapshots()
        .listen((querySnapshot) {
      setState(() {
        _list = querySnapshot.documents;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text(
              'Transaksi',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: _list.map((ds) {
                return ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('Rp${formatUang(ds.data['nominal'].toString())}'),
                      Text(ds.data['keterangan']),
                    ],
                  ),
                  subtitle: ds.data['VA']
                      ? Text(
                          'Virtual Account\n${formatTimestamp(ds.data['waktu'])}')
                      : FutureBuilder<DocumentSnapshot>(
                          future: Firestore.instance
                              .collection('pengguna')
                              .document(ds.data['customer'])
                              .get(),
                          builder: (BuildContext context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return Text(
                                  '${snapshot.data['nama']}\n${formatTimestamp(ds.data['waktu'])}');
                            } else {
                              return Text(
                                  '\n${formatTimestamp(ds.data['waktu'])}');
                            }
                          },
                        ),
                  isThreeLine: true,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
