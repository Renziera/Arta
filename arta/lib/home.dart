import 'package:Arta/page_akun.dart';
import 'package:Arta/page_home.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(),
      Container(color: Colors.cyan),
      Container(color: Colors.brown),
      AkunPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Arta'),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), title: Text('Home')),
          BottomNavigationBarItem(icon: Icon(Icons.ac_unit), title: Text('B')),
          BottomNavigationBarItem(icon: Icon(Icons.ac_unit), title: Text('C')),
          BottomNavigationBarItem(icon: Icon(Icons.person), title: Text('Akun')),
        ],
      ),
    );
  }
}
