import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/env.dart';
import 'pages/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final missingKeys = Env.missingKeys;
  if (missingKeys.isNotEmpty) {
    runApp(_ConfigErrorApp(missingKeys: missingKeys));
    return;
  }

  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabasePublishableKey,
  );
  await GoogleSignIn.instance.initialize(
    serverClientId: Env.googleWebClientId,
  );

  runApp(const SjkApp());
}

ThemeData _theme() => ThemeData(
  colorSchemeSeed: Colors.indigo,
  useMaterial3: true,
);

class SjkApp extends StatelessWidget {
  const SjkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SJK App',
      debugShowCheckedModeBanner: false,
      theme: _theme(),
      home: const AuthGate(),
    );
  }
}

/// Ditampilkan jika env.json belum diisi / tidak dipakai saat run.
class _ConfigErrorApp extends StatelessWidget {
  const _ConfigErrorApp({required this.missingKeys});

  final List<String> missingKeys;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _theme(),
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                'Konfigurasi belum lengkap: ${missingKeys.join(', ')}.\n\n'
                'Isi env.json lalu jalankan dengan '
                '--dart-define-from-file=env.json',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
