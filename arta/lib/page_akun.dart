import 'package:Arta/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AkunPage extends StatefulWidget {
  @override
  _AkunPageState createState() => _AkunPageState();
}

class _AkunPageState extends State<AkunPage> {
  String nama = '';
  String nomor = '';
  String saldo = '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    DocumentSnapshot ds = await Firestore.instance
        .collection('pengguna')
        .document(user.uid)
        .get();
    setState(() {
      nama = ds.data['nama'];
      nomor = ds.data['nomor'];
      saldo = ds.data['saldo'].toString();
      saldo = formatUang(saldo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
