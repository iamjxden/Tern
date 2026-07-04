import 'package:flutter/material.dart';

class AgentSpin extends StatefulWidget {
  final Widget child;
  final double speed;
  const AgentSpin({super.key, required this.child, this.speed = 1.0});
  @override State<AgentSpin> createState() => _AgentSpinState();
}

class _AgentSpinState extends State<AgentSpin> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: Duration(milliseconds: (2000 / widget.speed).round()))..repeat();
  }
  @override Widget build(BuildContext context) => RotationTransition(turns: _ctrl, child: widget.child);
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
}
