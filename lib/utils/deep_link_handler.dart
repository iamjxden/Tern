import 'package:flutter/material.dart';

class DeepLinkHandler {
  static Future<void> handleUri(Uri uri, BuildContext context) async {
    if (uri.scheme != 'tern') return;
    switch (uri.host) {
      case 'chat':
        break;
      case 'model':
        final modelName = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
        if (modelName != null) {}
        break;
      case 'open':
        break;
    }
  }
  static Uri buildChatLink() => Uri(scheme: 'tern', host: 'chat');
  static Uri buildModelLink(String modelName) => Uri(scheme: 'tern', host: 'model', path: modelName);
}
