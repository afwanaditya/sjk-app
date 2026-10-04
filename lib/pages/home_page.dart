import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../utils/error_messages.dart';
import '../widgets/loading_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.profile});

  final Profile profile;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = false;
  String? _error;

  Future<void> _logout() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthService.signOut();
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Berhasil login sebagai ${widget.profile.username}',
                  style: textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  ErrorText(_error!),
                ],
                const SizedBox(height: 32),
                LoadingButton(
                  label: 'Logout',
                  icon: const Icon(Icons.logout),
                  loading: _loading,
                  onPressed: _logout,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
