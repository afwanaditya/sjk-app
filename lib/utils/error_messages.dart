import 'dart:async';
import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Error dengan pesan yang sudah siap ditampilkan ke pengguna.
class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

const noConnectionMessage =
    'Tidak ada koneksi internet. Periksa koneksi Anda lalu coba lagi.';

/// Mengubah exception apa pun menjadi pesan Bahasa Indonesia.
String errorMessage(Object error) {
  if (_isNetworkError(error)) return noConnectionMessage;

  if (error is AppException) return error.message;

  if (error is GoogleSignInException) {
    if (error.code == GoogleSignInExceptionCode.canceled) {
      return 'Login Google dibatalkan.';
    }
    return 'Login Google gagal (${error.code.name}). Silakan coba lagi.';
  }

  if (error is AuthWeakPasswordException) return _weakPasswordMessage;

  if (error is AuthException) {
    switch (error.code) {
      case 'invalid_credentials':
        return 'Email/username atau password salah.';
      case 'email_exists':
      case 'user_already_exists':
        return 'Email sudah terdaftar. Silakan login.';
      case 'weak_password':
        return _weakPasswordMessage;
      case 'over_request_rate_limit':
      case 'over_email_send_rate_limit':
        return 'Terlalu banyak percobaan. Tunggu sebentar lalu coba lagi.';
    }
    return 'Terjadi kesalahan: ${error.message}';
  }

  if (error is PostgrestException) {
    // 23505 = unique_violation, 23514 = check_violation
    if (isProfileAlreadyExists(error)) {
      return 'Akun ini sudah punya username. Memuat ulang profil...';
    }
    if (error.code == '23505') return 'Username sudah dipakai.';
    if (error.code == '23514') return 'Format username tidak valid.';
    return 'Terjadi kesalahan: ${error.message}';
  }

  return 'Terjadi kesalahan. Silakan coba lagi.';
}

/// True jika insert profiles gagal karena user ini sudah punya baris
/// (primary key `id` bentrok), bukan karena username dipakai orang lain.
bool isProfileAlreadyExists(Object error) {
  if (error is! PostgrestException || error.code != '23505') return false;
  final info = '${error.message} ${error.details ?? ''}';
  return info.contains('profiles_pkey') || info.contains('Key (id)');
}

const _weakPasswordMessage =
    'Password terlalu lemah. Gunakan minimal 8 karakter dan kombinasi '
    'huruf serta angka.';

bool _isNetworkError(Object error) {
  if (error is SocketException ||
      error is TimeoutException ||
      error is AuthRetryableFetchException) {
    return true;
  }
  // Error jaringan dari PostgREST/RPC dibungkus sebagai ClientException
  // (package:http) yang berisi SocketException.
  final text = error.toString();
  return text.contains('SocketException') ||
      text.contains('Failed host lookup') ||
      text.contains('ClientException') ||
      text.contains('Connection refused') ||
      text.contains('Network is unreachable');
}
