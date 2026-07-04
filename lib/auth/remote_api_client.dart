import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/project.dart';

class RemoteApiException implements Exception {
  final String message;
  RemoteApiException(this.message);
  @override
  String toString() => message;
}

/// Talks to the Tern backend for everything that must survive a
/// reinstall: conversations, messages, projects and memory. This is
/// what makes "log back in and your chats are still there" actually
/// true, rather than data living only in the on-device store.
class RemoteApiClient {
  final http.Client _http;
  final String baseUrl;
  final Future<String?> Function() tokenProvider;

  RemoteApiClient({
    required this.tokenProvider,
    http.Client? client,
    String? baseUrl,
  })  : _http = client ?? http.Client(),
        baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  Future<Map<String, String>> _headers() async {
    final token = await tokenProvider();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  dynamic _unwrap(http.Response res) {
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 200 && res.statusCode < 300 && body['success'] == true) {
      return body['data'];
    }
    throw RemoteApiException(body['error'] as String? ?? 'Request failed');
  }

  // --- Conversations ---

  Future<List<Map<String, dynamic>>> listConversations() async {
    final res = await _http.get(
      Uri.parse('$baseUrl${AppConfig.conversationsEndpoint}'),
      headers: await _headers(),
    );
    return (_unwrap(res) as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> createConversation({
    String? title,
    String? projectId,
    String? modelId,
  }) async {
    final res = await _http.post(
      Uri.parse('$baseUrl${AppConfig.conversationsEndpoint}'),
      headers: await _headers(),
      body: jsonEncode({
        if (title != null) 'title': title,
        if (projectId != null) 'projectId': projectId,
        if (modelId != null) 'modelId': modelId,
      }),
    );
    return _unwrap(res) as Map<String, dynamic>;
  }

  Future<void> updateConversation(
    String id, {
    String? title,
    bool? isStarred,
    String? projectId,
  }) async {
    final res = await _http.put(
      Uri.parse('$baseUrl${AppConfig.conversationsEndpoint}/$id'),
      headers: await _headers(),
      body: jsonEncode({
        if (title != null) 'title': title,
        if (isStarred != null) 'isStarred': isStarred,
        if (projectId != null) 'projectId': projectId,
      }),
    );
    _unwrap(res);
  }

  Future<void> deleteConversation(String id) async {
    final res = await _http.delete(
      Uri.parse('$baseUrl${AppConfig.conversationsEndpoint}/$id'),
      headers: await _headers(),
    );
    _unwrap(res);
  }

  Future<List<Map<String, dynamic>>> listMessages(String conversationId) async {
    final res = await _http.get(
      Uri.parse('$baseUrl${AppConfig.conversationsEndpoint}/$conversationId/messages'),
      headers: await _headers(),
    );
    return (_unwrap(res) as List).cast<Map<String, dynamic>>();
  }

  Future<void> saveMessage(
    String conversationId, {
    required String role,
    required String content,
    String? toolCalls,
    String? stepsSummary,
  }) async {
    final res = await _http.post(
      Uri.parse('$baseUrl${AppConfig.conversationsEndpoint}/$conversationId/messages'),
      headers: await _headers(),
      body: jsonEncode({
        'role': role,
        'content': content,
        if (toolCalls != null) 'toolCalls': toolCalls,
        if (stepsSummary != null) 'stepsSummary': stepsSummary,
      }),
    );
    _unwrap(res);
  }

  // --- Projects ---

  Future<List<Project>> listProjects() async {
    final res = await _http.get(
      Uri.parse('$baseUrl${AppConfig.projectsEndpoint}'),
      headers: await _headers(),
    );
    final data = _unwrap(res) as List;
    return data.map((j) => Project.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<Project> createProject({
    required String name,
    String? description,
    String? instructions,
  }) async {
    final res = await _http.post(
      Uri.parse('$baseUrl${AppConfig.projectsEndpoint}'),
      headers: await _headers(),
      body: jsonEncode({
        'name': name,
        if (description != null) 'description': description,
        if (instructions != null) 'instructions': instructions,
      }),
    );
    return Project.fromJson(_unwrap(res) as Map<String, dynamic>);
  }

  Future<Project> updateProject(
    String id, {
    String? name,
    String? description,
    String? instructions,
  }) async {
    final res = await _http.put(
      Uri.parse('$baseUrl${AppConfig.projectsEndpoint}/$id'),
      headers: await _headers(),
      body: jsonEncode({
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (instructions != null) 'instructions': instructions,
      }),
    );
    return Project.fromJson(_unwrap(res) as Map<String, dynamic>);
  }

  Future<void> deleteProject(String id) async {
    final res = await _http.delete(
      Uri.parse('$baseUrl${AppConfig.projectsEndpoint}/$id'),
      headers: await _headers(),
    );
    _unwrap(res);
  }

  Future<ProjectKnowledgeItem> addProjectKnowledge(
    String projectId, {
    required String name,
    required String content,
  }) async {
    final res = await _http.post(
      Uri.parse('$baseUrl${AppConfig.projectsEndpoint}/$projectId/knowledge'),
      headers: await _headers(),
      body: jsonEncode({'name': name, 'content': content}),
    );
    return ProjectKnowledgeItem.fromJson(_unwrap(res) as Map<String, dynamic>);
  }

  Future<void> deleteProjectKnowledge(String projectId, String knowledgeId) async {
    final res = await _http.delete(
      Uri.parse('$baseUrl${AppConfig.projectsEndpoint}/$projectId/knowledge/$knowledgeId'),
      headers: await _headers(),
    );
    _unwrap(res);
  }

  // --- Memory ---

  Future<List<Map<String, dynamic>>> getMemory() async {
    final res = await _http.get(
      Uri.parse('$baseUrl${AppConfig.memoryEndpoint}'),
      headers: await _headers(),
    );
    return (_unwrap(res) as List).cast<Map<String, dynamic>>();
  }

  Future<void> upsertMemory(String key, String value) async {
    final res = await _http.put(
      Uri.parse('$baseUrl${AppConfig.memoryEndpoint}'),
      headers: await _headers(),
      body: jsonEncode({'key': key, 'value': value}),
    );
    _unwrap(res);
  }
}
