import 'dart:io';
import 'llama_bridge.dart';
import 'llama_types.dart';
import '../storage/file_cache.dart';
import '../core/errors/model_exception.dart';
import '../core/logger/humannode_logger.dart';

class ModelLoadResult {
  final LlamaModelInfo info;
  final int handle;
  final Duration loadTime;

  const ModelLoadResult({
    required this.info,
    required this.handle,
    required this.loadTime,
  });
}

class ModelLoader {
  final LlamaBridge llamaBridge;
  final FileCache fileCache;
  final Map<String, int> _loadedModels = {};
  final Map<String, LlamaModelInfo> _modelInfos = {};

  ModelLoader({required this.llamaBridge, required this.fileCache});

  Future<ModelLoadResult> load(String modelPath,
      {LlamaModelParams? params}) async {
    final file = File(modelPath);
    if (!await file.exists()) {
      throw ModelException('Model file not found: $modelPath');
    }

    final stat = await file.stat();
    final stopwatch = Stopwatch()..start();
    final mp = params ?? const LlamaModelParams();

    String name;
    try {
      name = modelPath.split('/').last.replaceAll('.gguf', '');
    } catch (_) {
      name = modelPath.hashCode.toRadixString(16);
    }

    final handle = llamaBridge.loadModel(modelPath, mp);
    stopwatch.stop();

    final info = LlamaModelInfo(
      name: name,
      path: modelPath,
      totalSizeBytes: stat.size,
      parameterCount: (stat.size ~/ 1.5).round(),
      contextSize: 8192,
      isLoaded: true,
    );

    _loadedModels[modelPath] = handle;
    _modelInfos[modelPath] = info;

    HumanNodeLogger.info(
        'Model loaded: $name (${stat.size} bytes) in ${stopwatch.elapsed.inMilliseconds}ms');
    return ModelLoadResult(info: info, handle: handle, loadTime: stopwatch.elapsed);
  }

  bool isLoaded(String modelPath) => _loadedModels.containsKey(modelPath);
  int? getHandle(String modelPath) => _loadedModels[modelPath];
  LlamaModelInfo? getInfo(String modelPath) => _modelInfos[modelPath];
  List<String> get loadedPaths => _loadedModels.keys.toList();
  List<LlamaModelInfo> get loadedInfos =>
      _modelInfos.values.where((i) => i.isLoaded).toList();
  int get loadedCount => _loadedModels.length;

  void unload(String modelPath) {
    final handle = _loadedModels.remove(modelPath);
    if (handle != null) llamaBridge.unloadModel(handle);
    _modelInfos.remove(modelPath);
    HumanNodeLogger.info('Model unloaded: ${modelPath.split('/').last}');
  }

  void unloadAll() {
    for (final entry in _loadedModels.entries) {
      llamaBridge.unloadModel(entry.value);
    }
    _loadedModels.clear();
    _modelInfos.clear();
    HumanNodeLogger.info('All models unloaded');
  }
}
