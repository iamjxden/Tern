import 'package:flutter/material.dart';

class ThinkingPulse extends StatefulWidget {
  final double size;
  final Color? color;
  const ThinkingPulse({super.key, this.size = 8, this.color});
  @override State<ThinkingPulse> createState() => _ThinkingPulseState();
}

class _ThinkingPulseState extends State<ThinkingPulse> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.onSurface;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = (_ctrl.value * 3 + i / 3) % 1;
            final alpha = 60 + (phase * 120).round();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: color.withAlpha(alpha.clamp(60, 180)),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }
}
