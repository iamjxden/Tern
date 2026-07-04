import 'package:flutter/material.dart';
class HumanNodeCard extends StatelessWidget {
  final Widget child; final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding; final EdgeInsetsGeometry? margin;
  const HumanNodeCard({super.key, required this.child, this.onTap, this.padding, this.margin});
  @override Widget build(BuildContext context) => Card(
    margin: margin, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16),
        child: Padding(padding: padding ?? const EdgeInsets.all(16), child: child)));
}
