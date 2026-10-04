import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/error_messages.dart';
import 'profile_service.dart';

class AuthService {
  const AuthService._();

  static GoTrueClient get _auth => Supabase.instance.client.auth;

  static Future<void> signUp({
    required String email,
    required String password,
  }) async {
    await _auth.signUp(email: email.trim(), password: password);
  }

  /// [identifier] berisi email (mengandung '@') atau username.
  static Future<void> signInWithIdentifier({
    required String identifier,
    required String password,
  }) async {
    final input = identifier.trim();

    final String email;
    if (input.contains('@')) {
      email = input;
    } else {
      final found = await ProfileService.getEmailByUsername(input.toLowerCase());
      if (found == null) {
        throw const AppException('Username atau password salah');
      }
      email = found;
    }

    await _auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> signInWithGoogle() async {
    final account = await GoogleSignIn.instance.authenticate();

    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw const AppException(
        'Login Google gagal: ID token tidak tersedia. '
        'Periksa GOOGLE_WEB_CLIENT_ID.',
      );
    }

    // Access token hanya dipakai bila sudah tersedia tanpa dialog tambahan.
    final authorization = await account.authorizationClient
        .authorizationForScopes(const ['email', 'profile']);

    await _auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: authorization?.accessToken,
    );
  }

  /// Keluar dari Supabase dan dari akun Google di perangkat.
  static Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Tetap lanjutkan logout Supabase walaupun sign out Google gagal.
    }
    await _auth.signOut();
  }
}
