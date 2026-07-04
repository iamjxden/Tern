import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _selectedModelKey = 'tern_selected_model_id';
const Object _sentinel = Object();

class InferenceState {
  final bool isLoaded;
  final bool isGenerating;
  final String? modelId;
  final String? modelName;
  final String? error;

  const InferenceState({
    this.isLoaded = false,
    this.isGenerating = false,
    this.modelId,
    this.modelName,
    this.error,
  });

  String? get modelPath => modelId;
  int? get contextSize => null;       // populated when a real inference engine reports it
  double? get tokensPerSecond => null;
  int? get totalTokens => null;

  InferenceState copyWith({
    bool? isLoaded,
    bool? isGenerating,
    String? modelId,
    String? modelName,
    Object? error = _sentinel,
  }) =>
      InferenceState(
        isLoaded: isLoaded ?? this.isLoaded,
        isGenerating: isGenerating ?? this.isGenerating,
        modelId: modelId ?? this.modelId,
        modelName: modelName ?? this.modelName,
        error: identical(error, _sentinel) ? this.error : error as String?,
      );
}

class InferenceNotifier extends StateNotifier<InferenceState> {
  final FlutterSecureStorage _storage;

  InferenceNotifier({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(),
        super(const InferenceState()) {
    _restoreSelection();
  }

  Future<void> _restoreSelection() async {
    final saved = await _storage.read(key: _selectedModelKey);
    if (saved != null && saved.isNotEmpty) {
      state = state.copyWith(modelId: saved, modelName: _displayName(saved), isLoaded: true);
    }
  }

  String _displayName(String modelId) {
    final parts = modelId.split('/');
    final tagParts = parts.last.split(':');
    return tagParts.first;
  }

  Future<void> selectModel(String modelId, {String? displayName}) async {
    await _storage.write(key: _selectedModelKey, value: modelId);
    state = state.copyWith(
      modelId: modelId,
      modelName: displayName ?? _displayName(modelId),
      isLoaded: true,
      error: null,
    );
  }

  void setGenerating(bool generating) =>
      state = state.copyWith(isGenerating: generating);

  void clearError() => state = state.copyWith(error: null);
}

final inferenceProvider =
    StateNotifierProvider<InferenceNotifier, InferenceState>(
  (ref) => InferenceNotifier(),
);
