import 'package:Arta/page_akun.dart';
import 'package:Arta/page_home.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _controller = ScrollController();
  int _currentIndex = 0;
  List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(),
      Container(color: Colors.cyan),
      SizedBox.shrink(),
      Container(color: Colors.brown),
      AkunPage(),
    ];
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
              title: Text('ASDF'),
              pinned: true,
              floating: true,
              elevation: 0,
              forceElevated: innerBoxIsScrolled,
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
                      margin: EdgeInsets.only(bottom: 0, left: 24, right: 24,),
                      child: SizedBox(height: 88, width: double.infinity,),
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
