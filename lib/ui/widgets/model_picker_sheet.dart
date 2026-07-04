import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../models/model_info.dart';
import '../../providers/models_provider.dart';

class ModelPickerSheet extends ConsumerStatefulWidget {
  final String? currentModelId;
  final ValueChanged<String> onSelected;

  const ModelPickerSheet({
    super.key,
    required this.currentModelId,
    required this.onSelected,
  });

  @override
  ConsumerState<ModelPickerSheet> createState() => _ModelPickerSheetState();
}

class _ModelPickerSheetState extends ConsumerState<ModelPickerSheet> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final modelsState = ref.watch(modelsProvider);
    final installed = modelsState.installedModels;
    final available = modelsState.availableModels;

    final visible = _showAll ? available : available.take(4).toList();

    return Container(
      decoration: const BoxDecoration(
        color: HumanNodeTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: HumanNodeTheme.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: HumanNodeTheme.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const Text(
                'Select model',
                style: TextStyle(
                  color: HumanNodeTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 8),
          ...visible.map((model) {
            final isSelected = model.id == widget.currentModelId;
            final isInstalled = installed.contains(model.id);
            final isUnavailable = !isInstalled && !model.cloud;
            return _ModelRow(
              model: model,
              isSelected: isSelected,
              isUnavailable: isUnavailable,
              onTap: isUnavailable
                  ? null
                  : () {
                      widget.onSelected(model.id);
                      Navigator.of(context).pop();
                    },
            );
          }),
          const Divider(color: HumanNodeTheme.border),
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                children: const [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Effort', style: TextStyle(color: HumanNodeTheme.textPrimary, fontWeight: FontWeight.w600)),
                        SizedBox(height: 2),
                        Text('Standard', style: TextStyle(color: HumanNodeTheme.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: HumanNodeTheme.textSecondary),
                ],
              ),
            ),
          ),
          const Divider(color: HumanNodeTheme.border),
          if (!_showAll)
            InkWell(
              onTap: () => setState(() => _showAll = true),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  children: const [
                    Expanded(
                      child: Text(
                        'More models',
                        style: TextStyle(color: HumanNodeTheme.textPrimary, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: HumanNodeTheme.textSecondary),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ModelRow extends StatelessWidget {
  final ModelInfo model;
  final bool isSelected;
  final bool isUnavailable;
  final VoidCallback? onTap;

  const _ModelRow({
    required this.model,
    required this.isSelected,
    required this.isUnavailable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        model.displayName,
                        style: TextStyle(
                          color: isUnavailable
                              ? HumanNodeTheme.textSecondary
                              : isSelected
                                  ? HumanNodeTheme.primary
                                  : HumanNodeTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      if (isUnavailable) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: HumanNodeTheme.surfaceCard,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Currently unavailable',
                            style: TextStyle(color: HumanNodeTheme.textSecondary, fontSize: 10),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    model.tagline,
                    style: TextStyle(
                      color: isSelected ? HumanNodeTheme.primary.withValues(alpha: 0.8) : HumanNodeTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check, color: HumanNodeTheme.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
