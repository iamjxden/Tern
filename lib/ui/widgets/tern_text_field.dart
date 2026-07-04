import 'package:flutter/material.dart';
class HumanNodeTextField extends StatelessWidget {
  final String? hint; final String? label; final TextEditingController? ctrl;
  final bool obscure; final int? maxLines; final TextInputType? type;
  final ValueChanged<String>? onChanged;
  const HumanNodeTextField({super.key, this.hint, this.label, this.ctrl,
      this.obscure = false, this.maxLines = 1, this.type, this.onChanged});
  @override Widget build(BuildContext context) => TextField(
    controller: ctrl, obscureText: obscure, maxLines: maxLines, keyboardType: type, onChanged: onChanged,
    decoration: InputDecoration(hintText: hint, labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), filled: true));
}
