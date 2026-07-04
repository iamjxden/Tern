import 'package:flutter/material.dart';
class HumanNodeSnackbar {
  static void show(BuildContext context, String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message), behavior: SnackBarBehavior.floating,
      backgroundColor: error ? Theme.of(context).colorScheme.error : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16), duration: const Duration(seconds: 3),
      action: SnackBarAction(label: 'OK', onPressed: () {}),
    ));
  }
}
