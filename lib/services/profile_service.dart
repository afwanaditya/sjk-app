import 'package:supabase_flutter/supabase_flutter.dart';

class Profile {
  const Profile({required this.id, required this.username, required this.email});

  factory Profile.fromMap(Map<String, dynamic> map) => Profile(
    id: map['id'] as String,
    username: map['username'] as String,
    email: map['email'] as String,
  );

  final String id;
  final String username;
  final String email;
}

class ProfileService {
  const ProfileService._();

  static SupabaseClient get _client => Supabase.instance.client;

  /// Profil milik user yang sedang login, atau null jika belum ada.
  static Future<Profile?> getMyProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final row = await _client
        .from('profiles')
        .select('id, username, email')
        .eq('id', user.id)
        .maybeSingle();
    return row == null ? null : Profile.fromMap(row);
  }

  static Future<bool> isUsernameAvailable(String username) async {
    final result = await _client.rpc(
      'is_username_available',
      params: {'p_username': username.trim().toLowerCase()},
    );
    return result as bool;
  }

  static Future<String?> getEmailByUsername(String username) async {
    final result = await _client.rpc(
      'get_email_by_username',
      params: {'p_username': username.trim().toLowerCase()},
    );
    return result as String?;
  }

  /// Membuat baris profiles untuk user yang sedang login.
  static Future<void> createProfile(String username) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AuthException('Sesi login tidak ditemukan.');
    }

    await _client.from('profiles').insert({
      'id': user.id,
      'username': username.trim().toLowerCase(),
      'email': user.email ?? '',
    });
  }
}
