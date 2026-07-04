import 'package:flutter/material.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stackTrace)? onError;
  const ErrorBoundary({super.key, required this.child, this.onError});
  @override State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.onError != null) return widget.onError!(_error!, _stackTrace);
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text('Something went wrong', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('$_error', style: const TextStyle(fontSize: 12, fontFamily: 'JetBrainsMono'), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: () => setState(() { _error = null; }), child: const Text('Retry')),
          ]),
        ),
      );
    }
    return widget.child;
  }
}
