import 'package:Arta/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseUser>(
      future: FirebaseAuth.instance.currentUser(),
      builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snap) {
        if (snap.connectionState == ConnectionState.done) {
          return StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance
                .collection('pengguna')
                .document(snap.data.uid)
                .collection('transaksi')
                .orderBy('waktu', descending: true)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError)
                return Center(child: Text('Error: ${snapshot.error}'));
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(child: CircularProgressIndicator());
                default:
                  return ListView(
                    children: snapshot.data.documents
                        .map((DocumentSnapshot document) =>
                            HistoryItem(doc: document))
                        .toList(),
                  );
              }
            },
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class HistoryItem extends StatelessWidget {
  final DocumentSnapshot doc;

  const HistoryItem({Key key, @required this.doc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String image;
    String keterangan = doc.data['keterangan'];
    if (keterangan.toLowerCase().contains('pembayaran')) {
      image = 'img/pembayaran.png';
    } else if (keterangan.toLowerCase().contains('kembalian')) {
      image = 'img/kembalian.png';
    } else if (keterangan.toLowerCase().contains('sedekah')) {
      image = 'img/alms.png';
    } else if (keterangan.toLowerCase().contains('investasi')) {
      image = 'img/investment.png';
    } else {
      image = 'img/dream_saving.png';
    }
    return ListTile(
      isThreeLine: true,
      onTap: () {},
      leading: Image.asset(image, height: 56),
      title: doc.data['merchant'] == null
          ? Text(keterangan)
          : FutureBuilder<DocumentSnapshot>(
              future: Firestore.instance
                  .collection('pengguna')
                  .document(doc.data['merchant'])
                  .get(),
              builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot){
                if(snapshot.connectionState == ConnectionState.done){
                  return Text('$keterangan ${snapshot.data.data['nama']}');
                }
                return Text(keterangan);
              },
            ),
      subtitle: Text(
          'Rp${formatUang(doc.data['nominal'].toString())}\n${formatTimestamp(doc.data['waktu'])}'),
    );
  }
}
