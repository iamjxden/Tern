import 'dart:io';

class MetalDevice {
  final String name;
  final int maxBufferSize;
  final bool isHeadless;

  const MetalDevice({required this.name, this.maxBufferSize = 4096, this.isHeadless = false});
}

class MetalDelegate {
  bool _available = false;
  MetalDevice? _device;
  bool _probed = false;

  bool get isAvailable => _available && Platform.isIOS;
  MetalDevice? get device => _device;
  bool get isProbed => _probed;

  Future<bool> probe() async {
    if (!Platform.isIOS) {
      _available = false;
      _probed = true;
      return false;
    }
    _device = const MetalDevice(name: 'Apple GPU', maxBufferSize: 4096);
    _available = true;
    _probed = true;
    return true;
  }

  Map<String, dynamic> getCapabilities() {
    if (!_available) return {'available': false};
    return {
      'available': true,
      'accelerator': 'Metal',
      'device': _device?.name ?? 'Unknown',
      'maxBufferSize': _device?.maxBufferSize ?? 0,
      'supportsSimdGroupReduce': true,
      'supportsBfloat16': true,
    };
  }

  int get recommendedGpuLayers => _available ? 99 : 0;
}
