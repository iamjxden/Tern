class CPUDelegate {
  int _cores = 4;
  String _arch = 'unknown';
  bool _probed = false;

  int get cores => _cores;
  String get arch => _arch;
  bool get isProbed => _probed;

  Future<void> probe() async {
    _cores = 4;
    _arch = 'arm64';
    _probed = true;
  }

  int optimalThreadCount({int requested = 4}) {
    return requested.clamp(1, _cores);
  }

  int optimalBatchThreadCount({int requested = 2}) {
    return requested.clamp(1, _cores ~/ 2);
  }

  Map<String, dynamic> getCapabilities() {
    return {
      'available': true,
      'type': 'CPU',
      'cores': _cores,
      'arch': _arch,
      'supportsNeon': true,
      'supportsFp16': true,
    };
  }
}
