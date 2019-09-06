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
            'target': result['target'],
            'progress': 0,
            'waktu': FieldValue.serverTimestamp(),
          });
        },
      ),
    );
  }
}
