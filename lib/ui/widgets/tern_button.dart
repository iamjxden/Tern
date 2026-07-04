import 'package:flutter/material.dart';
class HumanNodeButton extends StatelessWidget {
  final String label; final VoidCallback? onPressed; final IconData? icon;
  final bool isPrimary; final bool isLoading;
  const HumanNodeButton({super.key, required this.label, this.onPressed, this.icon, this.isPrimary = true, this.isLoading = false});
  @override Widget build(BuildContext context) {
    final child = isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
        : Row(mainAxisSize: MainAxisSize.min, children: [if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)], Text(label)]);
    return isPrimary ? FilledButton(onPressed: onPressed, child: child) : OutlinedButton(onPressed: onPressed, child: child);
  }
}
