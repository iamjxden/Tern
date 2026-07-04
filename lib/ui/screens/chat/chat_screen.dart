import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tern/providers/chat_provider.dart';
import 'package:tern/providers/inference_provider.dart';
import 'package:tern/providers/models_provider.dart';
import 'package:tern/providers/auth_provider.dart';
import 'package:tern/core/di/service_locator.dart';
import 'package:tern/config/theme.dart';
import 'chat_message_bubble.dart';
import 'chat_input_bar.dart';
import 'chat_typing_indicator.dart';
import 'package:tern/ui/widgets/model_picker_sheet.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with TickerProviderStateMixin {
  final _scrollController = ScrollController();
  StreamSubscription<String>? _outputSub;
  StreamSubscription? _stateSub;
  late final AnimationController _orbCtrl;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _orbFloat;
  late final Animation<double> _orbPulse;

  @override
  void initState() {
    super.initState();
    _orbCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _orbFloat =
        CurvedAnimation(parent: _orbCtrl, curve: Curves.easeInOut);
    _orbPulse =
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);

    final agentCtrl = ServiceLocator.agentController;
    _outputSub = agentCtrl.outputStream.listen((chunk) {
      ref.read(chatProvider.notifier).receiveAssistantStream(chunk);
      _scrollToBottom();
    });
    _stateSub = agentCtrl.stateStream.listen((s) {
      if (!s.isRunning) ref.read(chatProvider.notifier).finishStreaming();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    final infState = ref.read(inferenceProvider);
    if (!infState.isLoaded || infState.modelId == null) {
      _showModelPicker();
      return;
    }
    ref.read(chatProvider.notifier).sendMessage(text);
    _scrollToBottom();
    ServiceLocator.agentController.setModel(infState.modelId!);
    ServiceLocator.agentController.start(ref.read(chatProvider).messages);
  }

  void _showModelPicker() {
    final infState = ref.read(inferenceProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ModelPickerSheet(
        currentModelId: infState.modelId,
        onSelected: (modelId) {
          final models = ref.read(modelsProvider).availableModels;
          final model = models.where((m) => m.id == modelId).firstOrNull;
          ref.read(inferenceProvider.notifier).selectModel(
                modelId,
                displayName: model?.displayName,
              );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final infState = ref.watch(inferenceProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: HumanNodeTheme.surface,
      body: Stack(children: [
        _GradientBackground(size: size),
        SafeArea(
          child: Column(children: [
            _TopBar(
              modelName: infState.modelName,
              hasModel: infState.isLoaded,
              onModelTap: _showModelPicker,
              onHistoryTap: () => context.push('/home/conversations'),
              onNewChat: () =>
                  ref.read(chatProvider.notifier).newConversation(),
            ),
            Expanded(
              child: chatState.messages.isEmpty
                  ? _EmptyState(
                      orbFloat: _orbFloat,
                      orbPulse: _orbPulse,
                      onSuggestion: _sendMessage,
                      onBrowseModels: () => context.push('/home/models'),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      itemCount: chatState.messages.length +
                          (chatState.isStreaming ? 1 : 0),
                      itemBuilder: (ctx, i) {
                        if (i >= chatState.messages.length) {
                          return const ChatTypingIndicator();
                        }
                        return ChatMessageBubble(
                            message: chatState.messages[i]);
                      },
                    ),
            ),
            ChatInputBar(
              onSend: _sendMessage,
              isEnabled: true,
              onStop: null,
            ),
          ]),
        ),
      ]),
    );
  }

  @override
  void dispose() {
    _outputSub?.cancel();
    _stateSub?.cancel();
    _orbCtrl.dispose();
    _pulseCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _GradientBackground extends StatelessWidget {
  final Size size;
  const _GradientBackground({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(children: [
        Container(color: HumanNodeTheme.surface),
        Positioned(
          top: -100,
          left: -80,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                HumanNodeTheme.primary.withAlpha(30),
                Colors.transparent,
              ]),
            ),
          ),
        ),
        Positioned(
          top: 200,
          right: -100,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                HumanNodeTheme.orbPurple.withAlpha(20),
                Colors.transparent,
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String? modelName;
  final bool hasModel;
  final VoidCallback onModelTap;
  final VoidCallback onHistoryTap;
  final VoidCallback onNewChat;

  const _TopBar({
    required this.modelName,
    required this.hasModel,
    required this.onModelTap,
    required this.onHistoryTap,
    required this.onNewChat,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(56, 10, 8, 0),
      child: Row(children: [
        Expanded(
          child: GestureDetector(
            onTap: onModelTap,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: HumanNodeTheme.surfaceCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: hasModel
                      ? HumanNodeTheme.primary.withAlpha(80)
                      : HumanNodeTheme.border,
                  width: 0.8,
                ),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hasModel
                        ? const Color(0xFF22C55E)
                        : HumanNodeTheme.textSecondary,
                    boxShadow: hasModel
                        ? [
                            BoxShadow(
                                color:
                                    const Color(0xFF22C55E).withAlpha(120),
                                blurRadius: 6)
                          ]
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    modelName ?? 'Select Model',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: hasModel
                          ? HumanNodeTheme.textPrimary
                          : HumanNodeTheme.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down_rounded,
                    size: 16, color: HumanNodeTheme.textSecondary),
              ]),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.history_rounded,
              color: HumanNodeTheme.textSecondary),
          onPressed: onHistoryTap,
          iconSize: 20,
        ),
        IconButton(
          icon: const Icon(Icons.add_rounded,
              color: HumanNodeTheme.textSecondary),
          onPressed: onNewChat,
          iconSize: 22,
        ),
      ]),
    );
  }
}

class _EmptyState extends ConsumerWidget {
  final Animation<double> orbFloat;
  final Animation<double> orbPulse;
  final void Function(String) onSuggestion;
  final VoidCallback onBrowseModels;

  const _EmptyState({
    required this.orbFloat,
    required this.orbPulse,
    required this.onSuggestion,
    required this.onBrowseModels,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final size = MediaQuery.of(context).size;
    final displayName = user?.displayName ?? user?.name ?? user?.email.split('@').first;
    final welcomeText = displayName != null ? '$displayName returns!' : 'How can I help?';

    return SingleChildScrollView(
      child: SizedBox(
        height: size.height * 0.75,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: orbFloat,
              builder: (ctx, _) => Transform.translate(
                offset: Offset(0, -12 * orbFloat.value),
                child: _GlowingOrb(pulse: orbPulse),
              ),
            ),
            const SizedBox(height: 36),
            Text(
              welcomeText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: HumanNodeTheme.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                _Chip(Icons.lightbulb_rounded, 'Give me ideas', onSuggestion),
                _Chip(Icons.code_rounded, 'Write code', onSuggestion),
                _Chip(Icons.search_rounded, 'Search the web', onSuggestion),
                _Chip(Icons.translate_rounded, 'Translate text', onSuggestion),
                _Chip(Icons.task_alt_rounded, 'Help me plan', onSuggestion),
                _Chip(Icons.edit_rounded, 'Write something', onSuggestion),
              ],
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: onBrowseModels,
              icon: const Icon(Icons.download_rounded, size: 16),
              label: const Text('Browse Models'),
              style: TextButton.styleFrom(foregroundColor: HumanNodeTheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowingOrb extends StatelessWidget {
  final Animation<double> pulse;
  const _GlowingOrb({required this.pulse});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (ctx, _) {
        final scale = 1.0 + 0.06 * pulse.value;
        return SizedBox(
          width: 160,
          height: 160,
          child: Stack(alignment: Alignment.center, children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  HumanNodeTheme.primary.withAlpha(30),
                  Colors.transparent,
                ]),
              ),
            ),
            Transform.scale(
              scale: scale,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [
                      Color(0xFF818CF8),
                      Color(0xFF6366F1),
                      Color(0xFF4338CA),
                      Color(0xFF1E1B4B),
                    ],
                    stops: [0.0, 0.4, 0.7, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: HumanNodeTheme.primary.withAlpha(120),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                    BoxShadow(
                      color: HumanNodeTheme.orbPurple.withAlpha(80),
                      blurRadius: 60,
                      spreadRadius: 16,
                    ),
                  ],
                ),
                child: CustomPaint(painter: _OrbShimmerPainter(pulse.value)),
              ),
            ),
          ]),
        );
      },
    );
  }
}

class _OrbShimmerPainter extends CustomPainter {
  final double t;
  _OrbShimmerPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;
    final angle = -math.pi / 4 + t * math.pi / 8;
    final x = cx + r * 0.3 * math.cos(angle);
    final y = cy + r * 0.3 * math.sin(angle);
    final paint = Paint()
      ..shader = RadialGradient(colors: [
        Colors.white.withAlpha(60),
        Colors.transparent,
      ]).createShader(Rect.fromCircle(
          center: Offset(x, y), radius: r * 0.45));
    canvas.drawCircle(Offset(x, y), r * 0.45, paint);
  }

  @override
  bool shouldRepaint(_OrbShimmerPainter old) => old.t != t;
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final void Function(String) onTap;
  const _Chip(this.icon, this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(label),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: HumanNodeTheme.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: HumanNodeTheme.border, width: 0.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: HumanNodeTheme.primary),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  color: HumanNodeTheme.textSecondary,
                  fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}
