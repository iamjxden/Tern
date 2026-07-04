import 'package:flutter/material.dart';
import 'package:tern/config/theme.dart';

class ChatInputBar extends StatefulWidget {
  final void Function(String) onSend;
  final bool isEnabled;
  final VoidCallback? onStop;

  const ChatInputBar({
    super.key,
    required this.onSend,
    required this.isEnabled,
    this.onStop,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _ctrl = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      final has = _ctrl.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    widget.onSend(text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 14,
      ),
      decoration: const BoxDecoration(
        color: HumanNodeTheme.surface,
        border: Border(
            top: BorderSide(color: HumanNodeTheme.border, width: 0.5)),
      ),
      child: Row(children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: HumanNodeTheme.surfaceCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: HumanNodeTheme.border, width: 0.5),
            ),
            child: Row(children: [
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(Icons.attach_file_rounded,
                    color: HumanNodeTheme.textSecondary, size: 20),
                onPressed: () {},
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                padding: EdgeInsets.zero,
              ),
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  style: const TextStyle(
                      color: HumanNodeTheme.textPrimary, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Ask me anything...',
                    hintStyle: TextStyle(
                        color: HumanNodeTheme.textSecondary, fontSize: 14),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                    isDense: true,
                    filled: false,
                  ),
                  maxLines: 5,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: 4),
            ]),
          ),
        ),
        const SizedBox(width: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: widget.onStop != null
              ? _CircleBtn(
                  key: const ValueKey('stop'),
                  icon: Icons.stop_rounded,
                  color: Colors.red,
                  onTap: widget.onStop!,
                )
              : _hasText
                  ? _CircleBtn(
                      key: const ValueKey('send'),
                      icon: Icons.arrow_upward_rounded,
                      color: HumanNodeTheme.primary,
                      onTap: _send,
                    )
                  : _CircleBtn(
                      key: const ValueKey('mic'),
                      icon: Icons.mic_rounded,
                      color: HumanNodeTheme.surfaceElevated,
                      iconColor: HumanNodeTheme.textSecondary,
                      onTap: () {},
                    ),
        ),
      ]),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color? iconColor;
  final VoidCallback onTap;

  const _CircleBtn({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: iconColor == null
              ? [BoxShadow(color: color.withAlpha(80), blurRadius: 12)]
              : null,
        ),
        child: Icon(icon, color: iconColor ?? Colors.white, size: 20),
      ),
    );
  }
}
