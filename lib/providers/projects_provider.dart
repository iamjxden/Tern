import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/remote_api_client.dart';
import '../models/project.dart';
import 'auth_provider.dart';

class ProjectsState {
  final List<Project> projects;
  final bool isLoading;
  final String? error;

  const ProjectsState({this.projects = const [], this.isLoading = false, this.error});

  ProjectsState copyWith({List<Project>? projects, bool? isLoading, String? error}) =>
      ProjectsState(
        projects: projects ?? this.projects,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class ProjectsNotifier extends StateNotifier<ProjectsState> {
  final RemoteApiClient _api;

  ProjectsNotifier(this._api) : super(const ProjectsState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final projects = await _api.listProjects();
      state = state.copyWith(projects: projects, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<Project?> create({
    required String name,
    String? description,
  }) async {
    try {
      final project = await _api.createProject(name: name, description: description);
      state = state.copyWith(projects: [project, ...state.projects]);
      return project;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<void> delete(String id) async {
    try {
      await _api.deleteProject(id);
      state = state.copyWith(
        projects: state.projects.where((p) => p.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateInstructions(String id, String instructions) async {
    try {
      final updated = await _api.updateProject(id, instructions: instructions);
      state = state.copyWith(
        projects: state.projects.map((p) => p.id == id ? updated : p).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final remoteApiClientProvider = Provider<RemoteApiClient>((ref) {
  return RemoteApiClient(
    tokenProvider: () => ref.read(authProvider.notifier).currentToken(),
  );
});

final projectsProvider = StateNotifierProvider<ProjectsNotifier, ProjectsState>((ref) {
  return ProjectsNotifier(ref.watch(remoteApiClientProvider));
});
