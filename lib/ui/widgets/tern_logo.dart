import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TernLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const TernLogo({super.key, this.size = 64, this.color});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/branding/tern_logo.svg',
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}
