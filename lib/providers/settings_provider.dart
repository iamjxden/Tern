import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsState {
  final bool darkMode;
  final double fontSize;
  final bool hapticFeedback;
  final bool soundsEnabled;
  final bool voiceInput;
  final bool readAloud;
  final bool gpuAcceleration;
  final bool agentReflexion;
  final int maxAgentSteps;
  final double temperature;
  final double topP;
  final int maxTokens;
  final bool developerMode;

  const SettingsState({
    this.darkMode = false,
    this.fontSize = 16,
    this.hapticFeedback = true,
    this.soundsEnabled = true,
    this.voiceInput = false,
    this.readAloud = false,
    this.gpuAcceleration = true,
    this.agentReflexion = true,
    this.maxAgentSteps = 15,
    this.temperature = 0.7,
    this.topP = 0.9,
    this.maxTokens = 4096,
    this.developerMode = false,
  });

  SettingsState copyWith({
    bool? darkMode, double? fontSize, bool? hapticFeedback,
    bool? soundsEnabled, bool? voiceInput, bool? readAloud,
    bool? gpuAcceleration, bool? agentReflexion, int? maxAgentSteps,
    double? temperature, double? topP, int? maxTokens, bool? developerMode,
  }) => SettingsState(
    darkMode: darkMode ?? this.darkMode,
    fontSize: fontSize ?? this.fontSize,
    hapticFeedback: hapticFeedback ?? this.hapticFeedback,
    soundsEnabled: soundsEnabled ?? this.soundsEnabled,
    voiceInput: voiceInput ?? this.voiceInput,
    readAloud: readAloud ?? this.readAloud,
    gpuAcceleration: gpuAcceleration ?? this.gpuAcceleration,
    agentReflexion: agentReflexion ?? this.agentReflexion,
    maxAgentSteps: maxAgentSteps ?? this.maxAgentSteps,
    temperature: temperature ?? this.temperature,
    topP: topP ?? this.topP,
    maxTokens: maxTokens ?? this.maxTokens,
    developerMode: developerMode ?? this.developerMode,
  );
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState());

  void setDarkMode(bool v) => state = state.copyWith(darkMode: v);
  void setFontSize(double v) => state = state.copyWith(fontSize: v.clamp(12, 32));
  void setHaptic(bool v) => state = state.copyWith(hapticFeedback: v);
  void setSounds(bool v) => state = state.copyWith(soundsEnabled: v);
  void setVoiceInput(bool v) => state = state.copyWith(voiceInput: v);
  void setReadAloud(bool v) => state = state.copyWith(readAloud: v);
  void setGpuAcceleration(bool v) => state = state.copyWith(gpuAcceleration: v);
  void setMaxSteps(int v) => state = state.copyWith(maxAgentSteps: v.clamp(1, 50));
  void setTemperature(double v) => state = state.copyWith(temperature: v.clamp(0.0, 2.0));
  void setTopP(double v) => state = state.copyWith(topP: v.clamp(0.0, 1.0));
  void setMaxTokens(int v) => state = state.copyWith(maxTokens: v.clamp(256, 32768));
  void toggleReflexion() => state = state.copyWith(agentReflexion: !state.agentReflexion);
  void toggleDeveloper() => state = state.copyWith(developerMode: !state.developerMode);
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) => SettingsNotifier());
