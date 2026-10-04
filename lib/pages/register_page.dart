import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../utils/error_messages.dart';
import '../utils/validators.dart';
import '../widgets/loading_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required this.onRegistered});

  /// Dipanggil setelah baris profiles berhasil dibuat.
  final VoidCallback onRegistered;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _loading = false;
  String? _error;

  /// True jika signUp sudah berhasil tetapi insert profiles gagal,
  /// sehingga percobaan berikutnya hanya mengulang insert.
  bool _signedUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
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

      if (!_signedUp) {
        await AuthService.signUp(
          email: _emailController.text,
          password: _passwordController.text,
        );
        _signedUp = true;
      }

      await ProfileService.createProfile(username);

      widget.onRegistered();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountFieldsEnabled = !_loading && !_signedUp;

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _emailController,
                  enabled: accountFieldsEnabled,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: validateEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _usernameController,
                  enabled: !_loading,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  inputFormatters: const [LowerCaseTextFormatter()],
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    helperText: '3-20 karakter: huruf kecil, angka, atau _',
                    prefixIcon: Icon(Icons.alternate_email),
                    border: OutlineInputBorder(),
                  ),
                  validator: validateUsername,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  enabled: accountFieldsEnabled,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    helperText: 'Minimal $minPasswordLength karakter',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: validatePassword,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmController,
                  enabled: accountFieldsEnabled,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _loading ? null : _register(),
                  decoration: const InputDecoration(
                    labelText: 'Konfirmasi Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      validatePasswordConfirmation(v, _passwordController.text),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  ErrorText(_error!),
                ],
                const SizedBox(height: 24),
                LoadingButton(
                  label: 'Daftar',
                  loading: _loading,
                  onPressed: _register,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
