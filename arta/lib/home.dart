import 'package:Arta/page_akun.dart';
import 'package:Arta/page_history.dart';
import 'package:Arta/page_home.dart';
import 'package:Arta/page_qr.dart';
import 'package:Arta/page_wallet.dart';
import 'package:Arta/splash.dart';
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
      QRPage(),
      WalletPage(),
      AkunPage(),
      QRSayaPage(),
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
        onPressed: () {
          setState(() {
            if (_currentIndex == 2) {
              _currentIndex = 5;
            } else {
              _currentIndex = 2;
            }
          });
        },
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
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFF56CCF2),
                      Color(0xFF2F80ED),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {},
                  child: Image.asset('img/setting.png', height: 24),
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
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xFF56CCF2),
                            Color(0xFF2F80ED),
                          ],
                        ),
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
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    'ArtaWallet',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    'Rp${saldo ?? ''}',
                                    style: TextStyle(
                                      color: hijau,
                                      fontSize: 24,
                                    ),
                                  ),
                                  Text(
                                    'ArtaPoin 3594',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                              RaisedButton(
                                color: hijau,
                                textColor: Colors.white,
                                child: Text('TOP UP'),
                                onPressed: () {},
                              ),
                            ],
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
        currentIndex: (_currentIndex == 5 ? 2 : _currentIndex),
        onTap: (index) {
          setState(() {
            if (_currentIndex == 2 && index == 2) {
              _currentIndex = 5;
            } else {
              _currentIndex = index;
            }
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('img/menu_home.png', height: 24),
            activeIcon: Image.asset('img/menu_home_aktif.png', height: 24),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Image.asset('img/menu_history.png', height: 24),
            activeIcon: Image.asset('img/menu_history_aktif.png', height: 24),
            title: Text('History'),
          ),
          BottomNavigationBarItem(
            icon: Image.asset('img/qr_code.png'),
            title: Text(_currentIndex == 2 ? 'QR Saya' : 'Scan QR'),
          ),
          BottomNavigationBarItem(
            icon: Image.asset('img/menu_wallet.png', height: 24),
            activeIcon: Image.asset('img/menu_wallet_aktif.png', height: 24),
            title: Text('Wallet'),
          ),
          BottomNavigationBarItem(
            icon: Image.asset('img/menu_profil.png', height: 24),
            activeIcon: Image.asset('img/menu_profil_aktif.png', height: 24),
            title: Text('Profil'),
          ),
        ],
      ),
    );
  }
}
