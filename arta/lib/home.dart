import 'package:Arta/page_akun.dart';
import 'package:Arta/page_history.dart';
import 'package:Arta/page_home.dart';
import 'package:Arta/page_wallet.dart';
import 'package:Arta/util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _controller = ScrollController();
  int _currentIndex = 0;
  List<Widget> _pages;
  String nama;
  String saldo;

  @override
  void initState() {
    super.initState();
    fetchData();
    _pages = [
      HomePage(),
      HistoryPage(),
      SizedBox.shrink(),
      WalletPage(),
      AkunPage(),
    ];
  }

  void fetchData() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    Firestore.instance
        .collection('pengguna')
        .document(user.uid)
        .snapshots()
        .listen((ds) {
      setState(() {
        nama = ds.data['nama'];
        saldo = ds.data['saldo'].toString();
        saldo = formatUang(saldo);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Image.asset('img/qr_code.png'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: NestedScrollView(
        controller: _controller,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              title: Text('Hello, ${nama ?? ''}'),
              pinned: true,
              floating: true,
              elevation: 0,
              forceElevated: innerBoxIsScrolled,
              actions: <Widget>[
                FlatButton(
                  onPressed: () {},
                  child: Image.asset('img/setting.png'),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(96),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    Container(
                      color: Colors.white,
                      height: 96,
                      width: double.infinity,
                    ),
                    Container(
                      height: 96,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(72),
                        ),
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.only(
                        bottom: 0,
                        left: 24,
                        right: 24,
                      ),
                      child: SizedBox(
                        height: 88,
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      'Arta',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'Rp${saldo ?? ''}',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 18,
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(width: 36),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      'GoPay',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'Rp15.300',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 18,
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(width: 36),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      'OVO',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'Rp6.700',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 18,
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(width: 36),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      'JAGUNG',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'Rp635.400',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 18,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: _pages[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) return;
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('img/menu_home.png'),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Image.asset('img/menu_history.png'),
            title: Text('History'),
          ),
          BottomNavigationBarItem(
            icon: Image.asset('img/qr_code.png'),
            title: Text('Scan QR'),
          ),
          BottomNavigationBarItem(
            icon: Image.asset('img/menu_wallet.png'),
            title: Text('Wallet'),
          ),
          BottomNavigationBarItem(
            icon: Image.asset('img/menu_profil.png'),
            title: Text('Profil'),
          ),
        ],
      ),
    );
  }
}
