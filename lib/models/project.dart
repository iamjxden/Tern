class Project {
  final String id;
  final String name;
  final String? description;
  final String? instructions;
  final bool isPrivate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int conversationCount;
  final int knowledgeCount;

  const Project({
    required this.id,
    required this.name,
    this.description,
    this.instructions,
    this.isPrivate = true,
    required this.createdAt,
    required this.updatedAt,
    this.conversationCount = 0,
    this.knowledgeCount = 0,
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        instructions: json['instructions'] as String?,
        isPrivate: json['isPrivate'] as bool? ?? true,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        conversationCount: (json['_count']?['conversations'] as int?) ?? 0,
        knowledgeCount: (json['_count']?['knowledge'] as int?) ?? 0,
      );
}

class ProjectKnowledgeItem {
  final String id;
  final String name;
  final String content;
  final DateTime createdAt;

  const ProjectKnowledgeItem({
    required this.id,
    required this.name,
    required this.content,
    required this.createdAt,
  });

  factory ProjectKnowledgeItem.fromJson(Map<String, dynamic> json) => ProjectKnowledgeItem(
        id: json['id'] as String,
        name: json['name'] as String,
        content: json['content'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
