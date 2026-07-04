import 'package:flutter/material.dart';

class HumanNodePageTransitions {
  static PageRouteBuilder<T> slideFromBottom<T>(Widget page) => PageRouteBuilder(
    pageBuilder: (context, anim, sec) => page,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, anim, sec, child) => SlideTransition(
      position: Tween(begin: const Offset(0, 0.05), end: Offset.zero)
          .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
      child: FadeTransition(opacity: anim, child: child),
    ),
  );
}
