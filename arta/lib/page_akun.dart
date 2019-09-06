import 'package:Arta/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AkunPage extends StatefulWidget {
  @override
  _AkunPageState createState() => _AkunPageState();
}

class _AkunPageState extends State<AkunPage> {
  String nama;
  String nomor;

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        ListTile(
          title: Text(nama ?? ''),
          subtitle: Text(nomor ?? ''),
          onTap: (){},
        ),
        Divider(),
        ListTile(
          title: Text('Voucher Saya'),
          onTap: (){},
        ),
        Divider(),
        ListTile(
          title: Text('Pilihan Bahasa'),
          subtitle: Text('Bahasa Indonesia'),
          onTap: (){},
        ),
        Divider(),
        ListTile(
          title: Text('Bantuan'),
          onTap: (){},
        ),
        Divider(),
        ListTile(
          title: Text('Ketentuan Layanan'),
          onTap: (){},
        ),
        Divider(),
        ListTile(
          title: Text('Kebijakan Privasi'),
          onTap: (){},
        ),
      ],
    );
  }
}
