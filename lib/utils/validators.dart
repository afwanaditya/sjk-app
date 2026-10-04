import 'package:flutter/services.dart';

final _emailRegExp = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
final _usernameRegExp = RegExp(r'^[a-z0-9_]{3,20}$');

const minPasswordLength = 8;

String? validateRequired(String? value, String fieldName) {
  if (value == null || value.trim().isEmpty) return '$fieldName wajib diisi';
  return null;
}

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Email wajib diisi';
  if (!_emailRegExp.hasMatch(email)) return 'Format email tidak valid';
  return null;
}

String? validateUsername(String? value) {
  final username = value?.trim().toLowerCase() ?? '';
  if (username.isEmpty) return 'Username wajib diisi';
  if (!_usernameRegExp.hasMatch(username)) {
    return 'Username 3-20 karakter: huruf kecil, angka, atau _';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Password wajib diisi';
  if (value.length < minPasswordLength) {
    return 'Password minimal $minPasswordLength karakter';
  }
  return null;
}

String? validatePasswordConfirmation(String? value, String password) {
  if (value == null || value.isEmpty) return 'Konfirmasi password wajib diisi';
  if (value != password) return 'Konfirmasi password tidak cocok';
  return null;
}

/// Mengubah input menjadi huruf kecil saat diketik.
class LowerCaseTextFormatter extends TextInputFormatter {
  const LowerCaseTextFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toLowerCase());
  }
}
