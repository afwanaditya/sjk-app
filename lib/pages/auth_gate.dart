import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/profile_service.dart';
import '../utils/error_messages.dart';
import '../widgets/loading_button.dart';
import 'create_username_page.dart';
import 'home_page.dart';
import 'login_page.dart';

/// Menentukan halaman berdasarkan status login (onAuthStateChange)
/// dan keberadaan baris profiles.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final StreamSubscription<AuthState> _authSubscription;
  Session? _session;
  Future<Profile?>? _profileFuture;

  @override
  void initState() {
    super.initState();
    final auth = Supabase.instance.client.auth;
    _session = auth.currentSession;
    if (_session != null) _profileFuture = ProfileService.getMyProfile();

    _authSubscription = auth.onAuthStateChange.listen(
      (data) {
        final newSession = data.session;
        final userChanged = newSession?.user.id != _session?.user.id;
        setState(() {
          _session = newSession;
          if (userChanged) {
            _profileFuture = newSession == null
                ? null
                : ProfileService.getMyProfile();
          }
        });
      },
      // Error refresh token dsb. tidak boleh membuat aplikasi crash.
      onError: (Object _) {},
    );
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  void _reloadProfile() {
    if (!mounted) return;
    setState(() => _profileFuture = ProfileService.getMyProfile());
  }

  @override
  Widget build(BuildContext context) {
    if (_session == null) {
      return LoginPage(onProfileChanged: _reloadProfile);
    }

    return FutureBuilder<Profile?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return _ProfileErrorView(
            message: errorMessage(snapshot.error!),
            onRetry: _reloadProfile,
          );
        }

        final profile = snapshot.data;
        if (profile == null) {
          return CreateUsernamePage(onCreated: _reloadProfile);
        }
        return HomePage(profile: profile);
      },
    );
  }
}

class _ProfileErrorView extends StatelessWidget {
  const _ProfileErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ErrorText(message),
                const SizedBox(height: 16),
                LoadingButton(
                  label: 'Coba lagi',
                  loading: false,
                  onPressed: onRetry,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
