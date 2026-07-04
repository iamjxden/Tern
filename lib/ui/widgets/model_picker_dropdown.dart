import 'package:flutter/material.dart';
class ModelPickerDropdown extends StatelessWidget {
  final String? value; final List<String> models; final ValueChanged<String?> onChanged;
  const ModelPickerDropdown({super.key, this.value, required this.models, required this.onChanged});
  @override Widget build(BuildContext context) => DropdownButtonFormField<String>(
    value: value, items: models.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(), onChanged: onChanged,
    decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), filled: true));
}
