import 'package:Arta/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DreamSaving extends StatefulWidget {
  @override
  _DreamSavingState createState() => _DreamSavingState();
}

class _DreamSavingState extends State<DreamSaving> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dream Saving'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final TextEditingController namaController = TextEditingController();
          final TextEditingController targetController =
              TextEditingController();
          var result = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Tambah Impian'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        controller: namaController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(hintText: 'Nama'),
                      ),
                      TextField(
                        controller: targetController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(hintText: 'Target'),
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    RaisedButton(
                      color: Colors.blue,
                      textColor: Colors.white,
                      child: Text('Tambah'),
                      onPressed: () {
                        if (namaController.text.isEmpty ||
                            targetController.text.isEmpty) {
                          Fluttertoast.showToast(msg: 'Tidak boleh kosong');
                          return;
                        }
                        Navigator.of(context).pop({
                          'nama': namaController.text,
                          'target': targetController.text,
                        });
                      },
                    ),
                  ],
                );
              });
          if (result == null) return;
          FirebaseUser user = await FirebaseAuth.instance.currentUser();
          await Firestore.instance
              .collection('pengguna')
              .document(user.uid)
              .collection('dream')
              .add({
            'nama': result['nama'],
            'target': int.parse(result['target']),
            'progress': 0,
            'waktu': FieldValue.serverTimestamp(),
          });
        },
      ),
      body: FutureBuilder<FirebaseUser>(
        future: FirebaseAuth.instance.currentUser(),
        builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snap) {
          if (snap.connectionState == ConnectionState.done) {
            return StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection('pengguna')
                  .document(snap.data.uid)
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
                      children: snapshot.data.documents
                          .map((DocumentSnapshot document) {
                        return Card(
                          margin: EdgeInsets.all(16),
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
                                RaisedButton(
                                  color: hijau,
                                  textColor: Colors.white,
                                  child: Text('Tabung'),
                                  onPressed: () async {
                                    var result = await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text(
                                                'Tabung ${document.data['nama']}'),
                                            content: TextField(
                                              controller:
                                                  TextEditingController(),
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                  hintText: 'Nominal'),
                                              onSubmitted: (String s) =>
                                                  Navigator.of(context)
                                                      .pop(int.parse(s)),
                                            ),
                                          );
                                        });
                                    if (result == null) return;
                                    DocumentSnapshot ds = await Firestore
                                        .instance
                                        .collection('pengguna')
                                        .document(snap.data.uid)
                                        .get();
                                    if (ds.data['saldo'] < result) {
                                      Fluttertoast.showToast(
                                          msg: 'Saldo tidak cukup');
                                      return;
                                    }
                                    if (result + document.data['progress'] >=
                                        document.data['target']) {
                                      await ds.reference.updateData({
                                        'saldo': FieldValue.increment(
                                            document.data['progress'])
                                      });
                                      await document.reference.delete();
                                      Fluttertoast.showToast(msg: 'Target terpenuhi :)');
                                      return;
                                    }
                                    await ds.reference.updateData({
                                      'saldo': FieldValue.increment(-result)
                                    });
                                    await document.reference.updateData({
                                      'progress': FieldValue.increment(result)
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                }
              },
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
