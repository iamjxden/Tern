import 'package:flutter/material.dart';
class HumanNodeLoadingIndicator extends StatelessWidget {
  final String? message; final double size;
  const HumanNodeLoadingIndicator({super.key, this.message, this.size = 40});
  @override Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(width: size, height: size,
          child: CircularProgressIndicator(strokeWidth: 3, color: Theme.of(context).colorScheme.primary)),
      if (message != null) ...[const SizedBox(height: 16),
        Text(message!, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(160)))],
    ]));
}
