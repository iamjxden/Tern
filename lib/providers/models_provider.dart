import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../inference/ollama_client.dart';
import '../models/model_info.dart';

class ModelsState {
  final List<ModelInfo> availableModels;
  final List<String> installedModels;
  final Map<String, double> downloadProgress;
  final bool isLoadingCatalog;
  final bool ollamaReachable;
  final String? error;

  const ModelsState({
    this.availableModels = const [],
    this.installedModels = const [],
    this.downloadProgress = const {},
    this.isLoadingCatalog = false,
    this.ollamaReachable = false,
    this.error,
  });

  ModelInfo? get defaultModel =>
      availableModels.where((m) => m.isDefault).firstOrNull ??
      availableModels.where((m) => m.role == ModelRole.text).firstOrNull;

  String get defaultModelId => defaultModel?.id ?? 'ornith:9b';

  ModelsState copyWith({
    List<ModelInfo>? availableModels,
    List<String>? installedModels,
    Map<String, double>? downloadProgress,
    bool? isLoadingCatalog,
    bool? ollamaReachable,
    String? error,
  }) =>
      ModelsState(
        availableModels: availableModels ?? this.availableModels,
        installedModels: installedModels ?? this.installedModels,
        downloadProgress: downloadProgress ?? this.downloadProgress,
        isLoadingCatalog: isLoadingCatalog ?? this.isLoadingCatalog,
        ollamaReachable: ollamaReachable ?? this.ollamaReachable,
        error: error,
      );
}

class ModelsNotifier extends StateNotifier<ModelsState> {
  final OllamaClient _client;

  ModelsNotifier({OllamaClient? client})
      : _client = client ?? OllamaClient(),
        super(const ModelsState()) {
    _init();
  }

  Future<void> _init() async {
    await _loadCatalog();
    await refresh();
  }

  Future<void> _loadCatalog() async {
    state = state.copyWith(isLoadingCatalog: true, error: null);
    try {
      final raw = await rootBundle.loadString(AppConfig.modelsRegistryAsset);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final models = (json['models'] as List)
          .map((m) => ModelInfo.fromJson(m as Map<String, dynamic>))
          .toList();
      state = state.copyWith(availableModels: models, isLoadingCatalog: false);
    } catch (e) {
      state = state.copyWith(isLoadingCatalog: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    final reachable = await _client.isReachable();
    if (!reachable) {
      state = state.copyWith(ollamaReachable: false);
      return;
    }
    final installed = await _client.listInstalledModels();
    state = state.copyWith(ollamaReachable: true, installedModels: installed);
  }

  Stream<OllamaModelStatus> installModel(String modelId) async* {
    final progress = Map<String, double>.from(state.downloadProgress);
    progress[modelId] = 0;
    state = state.copyWith(downloadProgress: progress);

    await for (final status in _client.pullModel(modelId)) {
      if (status.downloadProgress != null) {
        final p = Map<String, double>.from(state.downloadProgress);
        p[modelId] = status.downloadProgress!;
        state = state.copyWith(downloadProgress: p);
      }
      if (status.installed) {
        final p = Map<String, double>.from(state.downloadProgress)..remove(modelId);
        final installed = List<String>.from(state.installedModels);
        if (!installed.contains(modelId)) installed.add(modelId);
        state = state.copyWith(downloadProgress: p, installedModels: installed);
      }
      yield status;
    }
  }

  Future<void> removeModel(String modelId) async {
    try {
      await _client.deleteModel(modelId);
      final installed = List<String>.from(state.installedModels)..remove(modelId);
      state = state.copyWith(installedModels: installed);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  bool isInstalled(String modelId) => state.installedModels.any(
        (m) => m == modelId || m.startsWith('${modelId.split(':').first}:'),
      );
}

final modelsProvider =
    StateNotifierProvider<ModelsNotifier, ModelsState>((ref) => ModelsNotifier());
