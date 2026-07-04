class AppConfig {
  static const String appName = 'Tern';
  static const String makerName = 'Aetheron';
  static const String tagline = 'Your AI workspace';
  static const String version = '1.0.0';
  static const int buildNumber = 1;

  static const String apiBaseUrl = 'https://api.aitern.dpdns.org';
  static const String authGoogleEndpoint = '/auth/google';
  static const String authSendOtpEndpoint = '/auth/email/send-otp';
  static const String authVerifyOtpEndpoint = '/auth/email/verify-otp';
  static const String userMeEndpoint = '/user/me';
  static const String conversationsEndpoint = '/conversations';
  static const String projectsEndpoint = '/projects';
  static const String memoryEndpoint = '/memory';

  static const String ollamaDefaultHost = 'http://127.0.0.1:11434';
  static const Duration ollamaConnectTimeout = Duration(seconds: 10);
  static const Duration ollamaReceiveTimeout = Duration(minutes: 5);

  static const int otpLength = 6;
  static const Duration otpExpiry = Duration(minutes: 5);
  static const Duration otpResendCooldown = Duration(seconds: 45);

  static const int defaultMaxTokens = 4096;
  static const int defaultContextWindow = 32768;
  static const double defaultTemperature = 0.7;
  static const double defaultTopP = 0.9;
  static const int defaultTopK = 40;
  static const double defaultRepetitionPenalty = 1.1;
  static const int maxAgentSteps = 25;
  static const int defaultAgentSteps = 15;
  static const int memoryWindowMessages = 50;
  static const int summaryThresholdTokens = 3000;
  static const int batteryThrottleThreshold = 20;
  static const int maxMessageLength = 32000;
  static const int maxToolOutputLength = 8000;
  static const int maxConversationTitleLength = 120;
  static const int streamBufferSize = 1024;
  static const Duration agentTimeout = Duration(minutes: 10);
  static const Duration toolTimeout = Duration(seconds: 30);
  static const Duration debounceDelay = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(seconds: 2);
  static const double minFontSize = 12.0;
  static const double maxFontSize = 32.0;
  static const double defaultFontSize = 16.0;
  static const int maxDownloadRetries = 3;
  static const String modelsRegistryAsset = 'assets/models/model_registry.json';
  static const String defaultSystemPromptAsset = 'assets/prompts/system_default.txt';
  static const String agentSystemPromptAsset = 'assets/prompts/system_agent.txt';
  static const String codingSystemPromptAsset = 'assets/prompts/system_coding.txt';
  static const String creativeSystemPromptAsset = 'assets/prompts/system_creative.txt';
}
