import 'package:share_plus/share_plus.dart';

class ShareUtil {
  static Future<void> shareText(String text, {String? subject}) async =>
      Share.share(text, subject: subject);

  static Future<void> shareConversation(String title, List<Map<String, String>> messages) async {
    final buffer = StringBuffer('$title\n\n');
    for (final msg in messages) {
      buffer.writeln('[${msg['role']}]: ${msg['content']}\n');
    }
    await Share.share(buffer.toString(), subject: title);
  }
}
