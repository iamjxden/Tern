import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'humannode_app.dart';
import 'core/di/service_locator.dart';
import 'core/logger/humannode_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  HumanNodeLogger.init();

  try {
    await ServiceLocator.init();
  } catch (e, st) {
    HumanNodeLogger.error('ServiceLocator init failed', e, st);
  }

  runApp(const ProviderScope(child: HumanNodeApp()));
}
