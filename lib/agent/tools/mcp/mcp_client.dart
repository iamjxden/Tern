import 'dart:convert';

class MCPTool {
  final String name;
  final String description;
  final Map<String, dynamic> inputSchema;

  const MCPTool({required this.name, required this.description, required this.inputSchema});

  factory MCPTool.fromJson(Map<String, dynamic> json) => MCPTool(
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        inputSchema: json['inputSchema'] as Map<String, dynamic>? ?? {},
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'inputSchema': inputSchema,
      };
}

class MCPClient {
  final String serverName;
  final String? serverVersion;
  bool _connected = false;
  final List<MCPTool> _tools = [];

  MCPClient(this.serverName, {this.serverVersion});

  bool get isConnected => _connected;
  List<MCPTool> get tools => List.unmodifiable(_tools);

  Future<void> connect() async {
    await Future.delayed(const Duration(milliseconds: 50));
    _connected = true;
  }

  Future<List<MCPTool>> listTools() async {
    if (!_connected) await connect();
    return _tools;
  }

  Future<String> callTool(String name, Map<String, dynamic> arguments) async {
    if (!_connected) await connect();
    return 'MCP tool "$name" executed on $serverName: ${jsonEncode(arguments)}';
  }

  Future<List<Map<String, dynamic>>> listResources() async {
    if (!_connected) await connect();
    return [];
  }

  void disconnect() {
    _connected = false;
    _tools.clear();
  }
}
