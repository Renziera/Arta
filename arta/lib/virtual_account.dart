import 'package:flutter/material.dart';

class VirtualAccount extends StatefulWidget {
  @override
  _VirtualAccountState createState() => _VirtualAccountState();
}

class _VirtualAccountState extends State<VirtualAccount> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Virtual Account'),
      ),
    );
  }
}