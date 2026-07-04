import 'package:flutter/material.dart';

class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({super.key});

  @override Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 88, height: 88,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [cs.primary.withAlpha(60), cs.tertiary.withAlpha(40)]),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(Icons.travel_explore_rounded, size: 44, color: cs.primary),
          ),
          const SizedBox(height: 28),
          Text('Welcome to Tern', style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Text('Your local AI workspace. Download a model to start chatting.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: cs.onSurface.withAlpha(140), height: 1.4)),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download_rounded, size: 20),
            label: const Text('Browse Models'),
            style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          ),
        ]),
      ),
    );
  }
}
