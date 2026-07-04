import 'dart:convert';
import 'tool.dart';
import 'tool_result.dart';
import 'builtin/web_search_tool.dart';
import 'builtin/calculator_tool.dart';
import 'builtin/datetime_tool.dart';
import 'builtin/file_read_tool.dart';
import 'builtin/file_write_tool.dart';
import 'builtin/bash_tool.dart';
import 'builtin/fetch_url_tool.dart';
import 'builtin/note_create_tool.dart';
import 'builtin/note_search_tool.dart';
import 'builtin/summary_tool.dart';
import 'builtin/memory_tool.dart';
import 'package:tern/core/logger/humannode_logger.dart';
import 'package:tern/storage/database.dart';

class ToolRegistry {
  final Map<String, Tool> _tools = {};
  final Set<String> _disabledTools = {};
  final Map<String, int> _callCounts = {};
  int _maxCallsPerTool = 25;
  final PresetDao _presetDao;

  ToolRegistry({required PresetDao presetDao}) : _presetDao = presetDao;

  Future<void> init() async {
    _registerDefaults();
    await _loadFromPresetDao();
  }

  void _registerDefaults() {
    _register(WebSearchTool());
    _register(CalculatorTool());
    _register(DatetimeTool());
    _register(FileReadTool());
    _register(FileWriteTool());
    _register(BashTool());
    _register(FetchUrlTool());
    _register(NoteCreateTool());
    _register(NoteSearchTool());
    _register(SummaryTool());
    _register(MemoryTool());
  }

  Future<void> _loadFromPresetDao() async {
    try {
      await _presetDao.getAll();
    } catch (_) {}
  }

  void _register(Tool tool) => _tools[tool.name] = tool;

  Tool? operator [](String name) => _tools[name];

  List<Tool> get enabledTools =>
      _tools.values.where((t) => !_disabledTools.contains(t.name)).toList();

  List<String> get toolNames => _tools.keys.toList();

  List<Map<String, dynamic>> getToolSchemas() => enabledTools
      .map((tool) => {
            'name': tool.name,
            'description': tool.description,
            'parameters': tool.parametersJsonSchema,
          })
      .toList();

  String getToolSchemasXml() {
    final buffer = StringBuffer('<available_tools>\n');
    for (final tool in enabledTools) {
      buffer.write(tool.schemaXml);
    }
    buffer.writeln('</available_tools>');
    return buffer.toString();
  }

  String getToolSchemasJson() {
    if (enabledTools.isEmpty) return '';
    final schemas = getToolSchemas();
    return const JsonEncoder.withIndent('  ').convert(schemas);
  }

  void disable(String name) {
    _disabledTools.add(name);
    HumanNodeLogger.info('Disabled: $name');
  }

  void enable(String name) {
    _disabledTools.remove(name);
    HumanNodeLogger.info('Enabled: $name');
  }

  bool isDisabled(String name) => _disabledTools.contains(name);
  bool isEnabled(String name) => !_disabledTools.contains(name);
  bool canCall(String name) => (_callCounts[name] ?? 0) < _maxCallsPerTool;
  void setMaxCallsPerTool(int max) => _maxCallsPerTool = max;

  Future<ToolResult> execute(String name, Map<String, dynamic> args) async {
    final tool = _tools[name];
    if (tool == null) return ToolFailure('Unknown tool', detail: name);
    if (_disabledTools.contains(name)) return const ToolFailure('Tool disabled');
    if (!canCall(name)) return ToolFailure('Call limit reached', detail: name);
    if (!tool.validateArgs(args)) {
      return ToolFailure('Invalid args', detail: jsonEncode(tool.parametersJsonSchema));
    }
    _callCounts[name] = (_callCounts[name] ?? 0) + 1;
    try {
      final result = await tool.execute(args);
      return ToolSuccess(result);
    } catch (e, st) {
      HumanNodeLogger.error('Tool failed: $name', e, st);
      return ToolFailure('Tool error', detail: e.toString());
    }
  }

  void resetCallCounts() => _callCounts.clear();
  int getCallCount(String name) => _callCounts[name] ?? 0;
}
