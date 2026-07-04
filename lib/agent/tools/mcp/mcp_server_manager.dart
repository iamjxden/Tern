import 'mcp_client.dart';
import 'package:tern/core/logger/humannode_logger.dart';

class MCPServerManager {
  final Map<String, MCPClient> _clients = {};

  List<MCPClient> get connectedClients =>
      _clients.values.where((c) => c.isConnected).toList();

  List<String> get serverNames => _clients.keys.toList();

  MCPClient registerServer(String name, {String? version}) {
    if (_clients.containsKey(name)) return _clients[name]!;
    final client = MCPClient(name, serverVersion: version);
    _clients[name] = client;
    HumanNodeLogger.info('MCP server registered: $name');
    return client;
  }

  Future<MCPClient> connectServer(String name) async {
    final client = _clients[name];
    if (client == null) throw StateError('MCP server not registered: $name');
    await client.connect();
    return client;
  }

  void removeServer(String name) {
    _clients[name]?.disconnect();
    _clients.remove(name);
    HumanNodeLogger.info('MCP server removed: $name');
  }

  MCPClient? getClient(String name) => _clients[name];

  void dispose() {
    for (final client in _clients.values) {
      client.disconnect();
    }
    _clients.clear();
  }
}
