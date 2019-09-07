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
          leading: Image.asset('img/user.png', height: 36),
          onTap: () {},
        ),
        Divider(),
        ListTile(
          title: Text('Voucher Saya'),
          leading: Image.asset('img/voucher.png', height: 36),
          onTap: () {},
        ),
        Divider(),
        ListTile(
          title: Text('Pilihan Bahasa'),
          subtitle: Text('Bahasa Indonesia'),
          leading: Image.asset('img/bahasa.png', height: 36),
          onTap: () {},
        ),
        Divider(),
        ListTile(
          title: Text('Bantuan'),
          leading: Image.asset('img/bantuan.png', height: 36),
          onTap: () {},
        ),
        Divider(),
        ListTile(
          title: Text('Ketentuan Layanan'),
          leading: Image.asset('img/ketentuan.png', height: 36),
          onTap: () {},
        ),
        Divider(),
        ListTile(
          title: Text('Kebijakan Privasi'),
          leading: Image.asset('img/privasi.png', height: 36),
          onTap: () {},
        ),
      ],
    );
  }
}
