import 'dart:math';

import 'package:Arta/home.dart';
import 'package:Arta/merchant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController nomorController = TextEditingController();
  final TextEditingController kodeController = TextEditingController();
  bool register = false;
  bool merchant = false;
  bool isKode = false;
  String verificationId;

  void tembakOTP() async {
    String nomor = nomorController.text;
    if (nomor.startsWith('0')) {
      nomor = nomor.replaceFirst('0', '+62');
    }
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: nomor,
      timeout: Duration(seconds: 30),
      codeAutoRetrievalTimeout: (String s) => verificationId = s,
      codeSent: (String s, [i]) {
        verificationId = s;
        Fluttertoast.showToast(msg: 'Kode telah dikirim ke $nomor');
        setState(() {
          isKode = true;
        });
      },
      verificationFailed: (e) =>
          Fluttertoast.showToast(msg: 'Verifikasi gagal\n${e.message}'),
      verificationCompleted: signIn,
    );
  }

  void signIn(AuthCredential credential) async {
    AuthResult result =
        await FirebaseAuth.instance.signInWithCredential(credential);
    if (result.user == null) {
      Fluttertoast.showToast(msg: 'Gagal verifikasi');
      setState(() {
        isKode = false;
      });
      return;
    }

    DocumentSnapshot ds = await Firestore.instance
        .collection('pengguna')
        .document(result.user.uid)
        .get();
    if (!ds.exists && !register) {
      Fluttertoast.showToast(msg: 'Belum terdaftar');
      await FirebaseAuth.instance.signOut();
      setState(() {
        isKode = false;
        register = true;
      });
      return;
    }
    if (!ds.exists && register) {
      var data = {
        'nama': namaController.text,
        'nomor': nomorController.text,
        'merchant': merchant,
        'saldo': 5000000 + Random().nextInt(5000000),
        'waktu_daftar': FieldValue.serverTimestamp(),
      };
      await ds.reference.setData(data);
    }

    if (ds.exists ? ds.data['merchant'] : merchant) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MerchantScreen()));
    } else {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${register ? 'Daftar' : 'Masuk'} ${register ? merchant ? 'Merchant' : 'Pengguna' : ''}'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 64.0, vertical: 16.0),
        child: Center(
          child: SingleChildScrollView(
            child: isKode
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextField(
                        controller: kodeController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(hintText: 'Kode'),
                      ),
                      SizedBox(height: 16),
                      RaisedButton(
                        onPressed: () {
                          if (kodeController.text.isEmpty) {
                            Fluttertoast.showToast(
                                msg: 'Kode tidak boleh kosong');
                            return;
                          }
                          AuthCredential credential =
                              PhoneAuthProvider.getCredential(
                                  smsCode: kodeController.text,
                                  verificationId: verificationId);
                          signIn(credential);
                        },
                        child: Text('VERIFIKASI'),
                      )
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      register
                          ? TextField(
                              controller: namaController,
                              keyboardType: TextInputType.text,
                              textAlign: TextAlign.center,
                              decoration:
                                  InputDecoration(hintText: 'Nama lengkap'),
                            )
                          : SizedBox.shrink(),
                      TextField(
                        controller: nomorController,
                        keyboardType: TextInputType.phone,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(hintText: 'Nomor telepon'),
                      ),
                      SizedBox(height: 16),
                      register
                          ? RaisedButton(
                              onPressed: () {
                                if (namaController.text.isEmpty) {
                                  Fluttertoast.showToast(
                                      msg: 'Nama tidak boleh kosong');
                                  return;
                                }
                                tembakOTP();
                              },
                              child: Text('REGISTER'),
                            )
                          : RaisedButton(
                              onPressed: tembakOTP,
                              child: Text('LOGIN'),
                            ),
                      SizedBox(height: 16),
                      register
                          ? FlatButton(
                              onPressed: () {
                                setState(() {
                                  merchant = !merchant;
                                });
                              },
                              child: Text(
                                  'Daftar ${merchant ? 'pengguna' : 'merchant'}'),
                            )
                          : SizedBox.shrink(),
                      FlatButton(
                        onPressed: () {
                          setState(() {
                            register = !register;
                          });
                        },
                        child: Text(
                            '${register ? 'Sudah daftar? Masuk di sini' : 'Belum daftar? Daftar di sini'}'),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
