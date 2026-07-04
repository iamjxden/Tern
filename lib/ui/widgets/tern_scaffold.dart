import 'package:flutter/material.dart';
class HumanNodeScaffold extends StatelessWidget {
  final Widget body; final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar; final Widget? fab;
  const HumanNodeScaffold({super.key, required this.body, this.appBar, this.bottomNavigationBar, this.fab});
  @override Widget build(BuildContext context) =>
      Scaffold(appBar: appBar, body: body, bottomNavigationBar: bottomNavigationBar, floatingActionButton: fab);
}
