// lib/utils/phone_formatter.dart

String formatPhoneNumber(String rawPhone) {
  // Удаляем всё, кроме цифр
  final digits = rawPhone.replaceAll(RegExp(r'\D'), '');

  // Приводим к формату +7 XXX XXX-XX-XX
  if (digits.length >= 11) {
    // Номер вида 79123456789 → +7 (912) 345-67-89
    return '+7 (${digits.substring(1, 4)}) ${digits.substring(4, 7)}-${digits.substring(7, 9)}-${digits.substring(9, 11)}';
  } else if (digits.length == 10) {
    // Номер без 7 → добавляем
    return '+7 (${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6, 8)}-${digits.substring(8, 10)}';
  } else {
    // Слишком короткий — просто показываем как есть (или с +7)
    return digits.isEmpty ? '' : '+7 $digits';
  }
}
