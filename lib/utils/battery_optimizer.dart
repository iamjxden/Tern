class BatteryOptimizer {
  int _batteryLevel = 100;
  static const int throttleThreshold = 20;

  void updateBatteryLevel(int level) => _batteryLevel = level.clamp(0, 100);
  bool get shouldThrottle => _batteryLevel <= throttleThreshold;
  int get batteryLevel => _batteryLevel;
  double get throttleFactor {
    if (_batteryLevel > 80) return 1.0;
    if (_batteryLevel > 50) return 0.8;
    if (_batteryLevel > 20) return 0.5;
    return 0.25;
  }
  int adjustedThreads(int requested) => (requested * throttleFactor).ceil().clamp(1, requested);
  int adjustedBatchSize(int requested) => (requested * throttleFactor).ceil().clamp(1, requested);
}
