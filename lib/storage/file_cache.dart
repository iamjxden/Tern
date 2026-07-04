import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../core/logger/tern_logger.dart';

class FileCache {
  late final String _cacheDir;
  bool _initialized = false;

  String get cacheDir => _cacheDir;

  Future<void> init() async {
    if (_initialized) return;
    final base = await getApplicationDocumentsDirectory();
    _cacheDir = '${base.path}/tern_models';
    final dir = Directory(_cacheDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _initialized = true;
    TernLogger.info('File cache initialized at: $_cacheDir');
  }

  Future<String> getModelPath(String modelName) async {
    if (!_initialized) await init();
    return '$_cacheDir/$modelName';
  }

  Future<bool> exists(String modelName) async {
    if (!_initialized) await init();
    final path = await getModelPath(modelName);
    return File(path).exists();
  }

  Future<List<String>> listCachedModels() async {
    if (!_initialized) await init();
    final directory = Directory(_cacheDir);
    if (!await directory.exists()) return [];
    final entities = await directory.list().toList();
    return entities
        .whereType<File>()
        .where((f) => f.path.endsWith('.gguf'))
        .map((f) => f.path.split('/').last)
        .toList();
  }

  Future<int> getCacheSize() async {
    if (!_initialized) await init();
    final directory = Directory(_cacheDir);
    if (!await directory.exists()) return 0;
    int total = 0;
    await for (final entity in directory.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        try {
          total += await entity.length();
        } catch (_) {}
      }
    }
    return total;
  }

  Future<int> getModelSize(String modelName) async {
    final path = await getModelPath(modelName);
    final file = File(path);
    if (!await file.exists()) return 0;
    return file.length();
  }

  Future<void> clear() async {
    if (!_initialized) await init();
    final directory = Directory(_cacheDir);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
      await directory.create(recursive: true);
      TernLogger.info('File cache cleared');
    }
  }

  Future<void> remove(String modelName) async {
    if (!_initialized) await init();
    final path = await getModelPath(modelName);
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
      TernLogger.info('Model removed from cache: $modelName');
    }
  }
}
