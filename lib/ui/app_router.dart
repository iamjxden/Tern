import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tern/ui/screens/splash_screen.dart';
import 'package:tern/ui/screens/main_shell.dart';
import 'package:tern/ui/screens/auth/login_screen.dart';
import 'package:tern/ui/screens/chat/chat_screen.dart';
import 'package:tern/ui/screens/models/models_screen.dart';
import 'package:tern/ui/screens/notes/notes_list_screen.dart';
import 'package:tern/ui/screens/notes/note_editor_screen.dart';
import 'package:tern/ui/screens/settings/settings_screen.dart';
import 'package:tern/ui/screens/settings/general_settings.dart';
import 'package:tern/ui/screens/settings/models_settings.dart';
import 'package:tern/ui/screens/settings/generation_settings.dart';
import 'package:tern/ui/screens/settings/agent_settings.dart';
import 'package:tern/ui/screens/settings/api_keys_screen.dart';
import 'package:tern/ui/screens/settings/storage_settings.dart';
import 'package:tern/ui/screens/settings/about_screen.dart';
import 'package:tern/ui/screens/settings/debug_screen.dart';
import 'package:tern/ui/screens/settings/capabilities_screen.dart';
import 'package:tern/ui/screens/settings/permissions_screen.dart';
import 'package:tern/ui/screens/settings/profile_screen.dart';
import 'package:tern/ui/screens/onboarding/onboarding_screen.dart';
import 'package:tern/ui/screens/conversations/conversations_list_screen.dart';
import 'package:tern/ui/screens/projects/projects_list_screen.dart';
import 'package:tern/ui/screens/projects/project_detail_screen.dart';
import 'package:tern/ui/screens/projects/project_knowledge_screen.dart';
import 'package:tern/ui/screens/artifacts/artifacts_screen.dart';
import 'package:tern/ui/screens/connectors/connectors_screen.dart';
import 'package:tern/ui/screens/connectors/browse_connectors_screen.dart';
import 'package:tern/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(ref),
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final loggingIn = state.matchedLocation == '/login';
      final onSplash = state.matchedLocation == '/splash';
      final onOnboarding = state.matchedLocation == '/onboarding';

      if (authState.status == AuthStatus.unknown) {
        return onSplash ? null : '/splash';
      }
      if (authState.status != AuthStatus.signedIn) {
        if (onOnboarding) return null;
        return loggingIn ? null : '/login';
      }
      if (loggingIn || onSplash) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      ShellRoute(
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const ChatScreen(),
            routes: [
              GoRoute(path: 'conversations', builder: (_, __) => const ConversationsListScreen()),
              GoRoute(path: 'projects', builder: (_, __) => const ProjectsListScreen()),
              GoRoute(
                path: 'projects/:projectId',
                builder: (_, state) => ProjectDetailScreen(
                  projectId: state.pathParameters['projectId'] ?? '',
                ),
                routes: [
                  GoRoute(
                    path: 'knowledge',
                    builder: (_, state) => ProjectKnowledgeScreen(
                      projectId: state.pathParameters['projectId'] ?? '',
                    ),
                  ),
                ],
              ),
              GoRoute(path: 'artifacts', builder: (_, __) => const ArtifactsScreen()),
              GoRoute(path: 'models', builder: (_, __) => const ModelsScreen()),
              GoRoute(path: 'notes', builder: (_, __) => const NotesListScreen()),
              GoRoute(
                path: 'note/:noteId',
                builder: (_, state) => NoteEditorScreen(
                  noteId: state.pathParameters['noteId'] ?? '',
                  title: state.uri.queryParameters['title'] ?? '',
                  content: state.uri.queryParameters['content'] ?? '',
                ),
              ),
              GoRoute(
                path: 'settings',
                builder: (_, __) => const SettingsScreen(),
                routes: [
                  GoRoute(path: 'general', builder: (_, __) => const GeneralSettings()),
                  GoRoute(path: 'models', builder: (_, __) => const ModelsSettings()),
                  GoRoute(path: 'generation', builder: (_, __) => const GenerationSettings()),
                  GoRoute(path: 'agent', builder: (_, __) => const AgentSettings()),
                  GoRoute(path: 'api-keys', builder: (_, __) => const ApiKeysScreen()),
                  GoRoute(path: 'storage', builder: (_, __) => const StorageSettings()),
                  GoRoute(path: 'about', builder: (_, __) => const AboutScreen()),
                  GoRoute(path: 'debug', builder: (_, __) => const DebugScreen()),
                  GoRoute(path: 'capabilities', builder: (_, __) => const CapabilitiesScreen()),
                  GoRoute(path: 'permissions', builder: (_, __) => const PermissionsScreen()),
                  GoRoute(path: 'profile', builder: (_, __) => const ProfileScreen()),
                  GoRoute(path: 'connectors', builder: (_, __) => const ConnectorsScreen()),
                  GoRoute(path: 'connectors/browse', builder: (_, __) => const BrowseConnectorsScreen()),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// Bridges Riverpod auth state changes into something GoRouter's
/// refreshListenable can subscribe to, so navigation re-evaluates the
/// redirect callback the moment sign-in/sign-out happens instead of
/// only on the next manual navigation.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Ref ref) {
    ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
  }
}
