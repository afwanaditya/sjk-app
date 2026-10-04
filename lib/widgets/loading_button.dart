import 'package:flutter/material.dart';

/// Tombol lebar penuh yang menampilkan spinner saat [loading].
/// Tombol nonaktif jika [onPressed] null atau sedang loading.
class LoadingButton extends StatelessWidget {
  const LoadingButton({
    super.key,
    required this.label,
    required this.loading,
    required this.onPressed,
    this.icon,
    this.outlined = false,
  });

  final String label;
  final bool loading;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final onTap = loading ? null : onPressed;
    final Widget child = loading
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(label);

    final Widget button;
    if (outlined) {
      button = icon == null || loading
          ? OutlinedButton(onPressed: onTap, child: child)
          : OutlinedButton.icon(onPressed: onTap, icon: icon, label: child);
    } else {
      button = icon == null || loading
          ? FilledButton(onPressed: onTap, child: child)
          : FilledButton.icon(onPressed: onTap, icon: icon, label: child);
    }

    return SizedBox(width: double.infinity, height: 48, child: button);
  }
}

/// Teks error di dalam form.
class ErrorText extends StatelessWidget {
  const ErrorText(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(message, style: TextStyle(color: colors.onErrorContainer)),
    );
  }
}
