import 'package:flutter/material.dart';

class MessageSlideIn extends StatefulWidget {
  final Widget child;
  const MessageSlideIn({super.key, required this.child});
  @override State<MessageSlideIn> createState() => _MessageSlideInState();
}

class _MessageSlideInState extends State<MessageSlideIn> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _offset;
  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _offset = Tween(begin: const Offset(0, 0.08), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }
  @override Widget build(BuildContext context) => SlideTransition(position: _offset, child: FadeTransition(opacity: _ctrl, child: widget.child));
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
}
