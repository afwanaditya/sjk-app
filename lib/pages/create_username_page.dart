import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/profile_service.dart';
import '../utils/error_messages.dart';
import '../utils/validators.dart';
import '../widgets/loading_button.dart';

class CreateUsernamePage extends StatefulWidget {
  const CreateUsernamePage({super.key, required this.onCreated});

  /// Dipanggil setelah baris profiles berhasil dibuat.
  final VoidCallback onCreated;

  @override
  State<CreateUsernamePage> createState() => _CreateUsernamePageState();
}

class _CreateUsernamePageState extends State<CreateUsernamePage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final username = _usernameController.text.trim().toLowerCase();

      if (!await ProfileService.isUsernameAvailable(username)) {
        throw const AppException('Username sudah dipakai.');
      }
      await ProfileService.createProfile(username);

      widget.onCreated();
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(e));
      // Profil akun ini ternyata sudah ada: minta AuthGate cek ulang
      // agar langsung pindah ke halaman home.
      if (isProfileAlreadyExists(e)) widget.onCreated();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = Supabase.instance.client.auth.currentUser?.email;

    return Scaffold(
      appBar: AppBar(title: const Text('Buat Username')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  email == null
                      ? 'Buat username untuk akun Anda.'
                      : 'Buat username untuk akun $email.',
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _usernameController,
                  enabled: !_loading,
                  textInputAction: TextInputAction.done,
                  autocorrect: false,
                  inputFormatters: const [LowerCaseTextFormatter()],
                  onFieldSubmitted: (_) => _loading ? null : _save(),
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    helperText: '3-20 karakter: huruf kecil, angka, atau _',
                    prefixIcon: Icon(Icons.alternate_email),
                    border: OutlineInputBorder(),
                  ),
                  validator: validateUsername,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  ErrorText(_error!),
                ],
                const SizedBox(height: 24),
                LoadingButton(
                  label: 'Simpan',
                  loading: _loading,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
