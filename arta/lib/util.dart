String formatUang(String s){
  String result = s[0];
  for (int i = 1; i < s.length; i++) {
    if((s.length - i) % 3 == 0) result += '.';
    result += s[i];
  }
  return result;
}

String formatUangSpasi(String s){
  String result = s[0];
  for (int i = 1; i < s.length; i++) {
    if((s.length - i) % 3 == 0) result += ' ';
    result += s[i];
  }
  return result;
}