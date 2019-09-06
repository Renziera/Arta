import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

String formatUang(String s) {
  String result = s[0];
  for (int i = 1; i < s.length; i++) {
    if ((s.length - i) % 3 == 0) result += '.';
    result += s[i];
  }
  return result;
}

String formatUangSpasi(String s) {
  String result = s[0];
  for (int i = 1; i < s.length; i++) {
    if ((s.length - i) % 3 == 0) result += ' ';
    result += s[i];
  }
  return result;
}

String formatTimestamp(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();
  String s = '';
  s += hari[dateTime.weekday];
  s += ', ';
  s += dateTime.day.toString();
  s += ' ';
  s += bulan[dateTime.month - 1];
  s += ' ';
  s += dateTime.year.toString();
  s += ' ';
  s += dateTime.hour.toString();
  s += ':';
  s += dateTime.minute.toString();
  return s;
}

const Color hijau = const Color(0xFF44D388);

const hari = [
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu',
];

const bulan = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'December',
];
