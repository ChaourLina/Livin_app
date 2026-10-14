String? toInternationalNumber(String raw) {
  var digits = raw.replaceAll(RegExp(r'[^0-9+]'), '');
  if (digits.startsWith('+')) {
    digits = digits.substring(1);
  } else if (digits.startsWith('00')) {
    digits = digits.substring(2);
  } else if (digits.startsWith('0')) {
    digits = '213${digits.substring(1)}';
  } else if (digits.length == 9) {
    digits = '213$digits';
  }
  digits = digits.replaceAll('+', '');
  if (digits.length < 9) return null;
  return digits;
}