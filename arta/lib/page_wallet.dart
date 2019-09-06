import 'package:flutter/material.dart';

class WalletPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: <Widget>[
          SizedBox(height: 24),
          Image.asset('img/wallet_arta.png'),
          Image.asset('img/wallet_jagung.png'),
        ],
      ),
    );
  }
}
