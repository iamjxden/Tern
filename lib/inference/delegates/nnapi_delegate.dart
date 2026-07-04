import 'dart:io';

class NNAPIDevice {
  final String name;
  final String type;
  final int memoryBytes;

  const NNAPIDevice({required this.name, required this.type, this.memoryBytes = 0});
}

class NNAPIDelegate {
  bool _available = false;
  List<NNAPIDevice> _devices = [];
  bool _probed = false;

  bool get isAvailable => _available && Platform.isAndroid;
  List<NNAPIDevice> get devices => _devices;
  bool get isProbed => _probed;

  Future<bool> probe() async {
    if (!Platform.isAndroid) {
      _available = false;
      _probed = true;
      return false;
    }
    _devices = [
      const NNAPIDevice(name: 'CPU', type: 'cpu', memoryBytes: 0),
      const NNAPIDevice(name: 'GPU', type: 'gpu', memoryBytes: 4 * 1024 * 1024 * 1024),
    ];
    _available = true;
    _probed = true;
    return true;
  }

  Map<String, dynamic> getCapabilities() {
    if (!_available) return {'available': false};
    return {
      'available': true,
      'accelerator': 'NNAPI',
      'devices': _devices.map((d) => {'name': d.name, 'type': d.type}).toList(),
    };
  }

  int get recommendedGpuLayers {
    if (!_available) return 0;
    final gpu = _devices.where((d) => d.type == 'gpu').firstOrNull;
    if (gpu != null && gpu.memoryBytes > 2 * 1024 * 1024 * 1024) return 33;
    return 0;
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
