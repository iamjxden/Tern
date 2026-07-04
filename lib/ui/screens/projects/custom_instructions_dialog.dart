import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class CustomInstructionsDialog extends StatefulWidget {
  final String? initialValue;
  const CustomInstructionsDialog({super.key, this.initialValue});

  @override
  State<CustomInstructionsDialog> createState() => _CustomInstructionsDialogState();
}

class _CustomInstructionsDialogState extends State<CustomInstructionsDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: HumanNodeTheme.surfaceElevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set custom instructions',
              style: TextStyle(color: HumanNodeTheme.textPrimary, fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Instruct Tern how to behave and respond for all chats in this project',
              style: TextStyle(color: HumanNodeTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: HumanNodeTheme.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _controller,
                maxLines: 5,
                style: const TextStyle(color: HumanNodeTheme.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Instruct Tern with prompts like: Use a professional tone, '
                      'Use concise and simple wording, You are an expert in Astrophysics, etc.',
                  hintStyle: TextStyle(color: HumanNodeTheme.textSecondary, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel', style: TextStyle(color: HumanNodeTheme.textSecondary)),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
                  child: const Text('Save',
                      style: TextStyle(color: HumanNodeTheme.textPrimary, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
