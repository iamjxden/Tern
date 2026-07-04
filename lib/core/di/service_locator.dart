import 'package:tern/storage/database.dart';
import 'package:tern/storage/file_cache.dart';
import 'package:tern/storage/secure_store.dart';
import 'package:tern/inference/ollama_client.dart';
import 'package:tern/inference/ollama_inference_engine.dart';
import 'package:tern/inference/tokenizer.dart';
import 'package:tern/agent/tools/tool_registry.dart';
import 'package:tern/agent/agent_loop.dart';
import 'package:tern/agent/agent_controller.dart';
import 'package:tern/agent/agent_memory.dart';
import 'package:tern/agent/ollama_prompt_builder.dart';
import 'package:tern/core/logger/humannode_logger.dart';

class ServiceLocator {
  static late AppDatabase db;
  static late SecureStore secureStore;
  static late ConversationDao conversationDao;
  static late MessageDao messageDao;
  static late NoteDao noteDao;
  static late PresetDao presetDao;
  static late SettingsDao settingsDao;
  static late FileCache fileCache;
  static late OllamaClient ollamaClient;
  static late OllamaInferenceEngine inferenceEngine;
  static late HumanNodeTokenizer tokenizer;
  static late ToolRegistry toolRegistry;
  static late AgentMemory agentMemory;
  static late OllamaPromptBuilder ollamaPromptBuilder;
  static late AgentLoop agentLoop;
  static late AgentController agentController;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    await _bootstrap();
    _initialized = true;
    HumanNodeLogger.info('ServiceLocator initialized — Tern by Aetheron');
  }

  static Future<void> _bootstrap() async {
    db = AppDatabase();
    conversationDao = db.conversationDao;
    messageDao = db.messageDao;
    noteDao = db.noteDao;
    presetDao = db.presetDao;
    settingsDao = db.settingsDao;

    secureStore = SecureStore();

    fileCache = FileCache();
    try {
      await fileCache.init();
    } catch (e) {
      HumanNodeLogger.warn('FileCache init failed: $e');
    }

    ollamaClient = OllamaClient();
    inferenceEngine = OllamaInferenceEngine(client: ollamaClient);
    tokenizer = HumanNodeTokenizer();

    toolRegistry = ToolRegistry(presetDao: presetDao);
    try {
      await toolRegistry.init();
    } catch (e) {
      HumanNodeLogger.warn('ToolRegistry init failed: $e');
    }

    agentMemory = AgentMemory(messageDao: messageDao);
    ollamaPromptBuilder = OllamaPromptBuilder(
      toolRegistry: toolRegistry,
      agentMemory: agentMemory,
    );

    try {
      await ollamaPromptBuilder.loadPrompts();
    } catch (e) {
      HumanNodeLogger.warn('Prompt load failed, using fallback: $e');
    }

    agentLoop = AgentLoop(
      inferenceEngine: inferenceEngine,
      toolRegistry: toolRegistry,
      agentMemory: agentMemory,
      promptBuilder: ollamaPromptBuilder,
    );
    agentController = AgentController(agentLoop: agentLoop);
  }

  static Future<void> reset() async {
    if (!_initialized) return;
    agentController.dispose();
    agentLoop.dispose();
    await db.close();
    _initialized = false;
  }
}
