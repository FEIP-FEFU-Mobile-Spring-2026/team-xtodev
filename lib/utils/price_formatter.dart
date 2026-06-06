String formatPrice(int kopecks) {
  final rubles = kopecks ~/ 100;
  final s = rubles.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) {
      buf.writeCharCode(0x00A0);
    }
    buf.write(s[i]);
  }
  buf.write(' ₽');
  return buf.toString();
}
