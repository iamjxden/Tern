import 'package:flutter/services.dart';

class ClipboardUtil {
  static Future<void> copy(String text) => Clipboard.setData(ClipboardData(text: text));
  static Future<String?> paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text;
  }
}
