String formatPhoneNumber(String rawPhone) {
  final digits = rawPhone.replaceAll(RegExp(r'\D'), '');
  if (digits.length >= 11) {
    return '+7 (${digits.substring(1, 4)}) ${digits.substring(4, 7)}-${digits.substring(7, 9)}-${digits.substring(9, 11)}';
  } else if (digits.length == 10) {
    return '+7 (${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6, 8)}-${digits.substring(8, 10)}';
  } else {
    return digits.isEmpty ? '' : '+7 $digits';
  }
}
