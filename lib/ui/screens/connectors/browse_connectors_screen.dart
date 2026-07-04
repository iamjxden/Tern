import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';
import '../../../models/connector.dart';

class BrowseConnectorsScreen extends StatefulWidget {
  const BrowseConnectorsScreen({super.key});

  @override
  State<BrowseConnectorsScreen> createState() => _BrowseConnectorsScreenState();
}

class _BrowseConnectorsScreenState extends State<BrowseConnectorsScreen> {
  ConnectorCategory? _selectedCategory;
  final _searchController = TextEditingController();
  final Set<String> _connecting = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    var connectors = ConnectorDirectory.byCategory(_selectedCategory);
    if (query.isNotEmpty) {
      connectors = connectors.where((c) => c.name.toLowerCase().contains(query)).toList();
    }

    return Scaffold(
      backgroundColor: HumanNodeTheme.surface,
      appBar: AppBar(
        backgroundColor: HumanNodeTheme.surface,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('Browse connectors'),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: HumanNodeTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: HumanNodeTheme.border),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(color: HumanNodeTheme.textPrimary, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Search connectors',
                    hintStyle: TextStyle(color: HumanNodeTheme.textSecondary),
                    prefixIcon: Icon(Icons.search, color: HumanNodeTheme.textSecondary, size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _CategoryChip(
                    label: 'All',
                    selected: _selectedCategory == null,
                    onTap: () => setState(() => _selectedCategory = null),
                  ),
                  ...ConnectorCategory.values.map((cat) => _CategoryChip(
                        label: ConnectorDirectory.categoryLabel(cat),
                        selected: _selectedCategory == cat,
                        onTap: () => setState(() => _selectedCategory = cat),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                itemCount: connectors.length,
                itemBuilder: (context, i) {
                  final c = connectors[i];
                  final isConnecting = _connecting.contains(c.id);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: HumanNodeTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: HumanNodeTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            c.name.isNotEmpty ? c.name[0] : '?',
                            style: const TextStyle(color: HumanNodeTheme.textPrimary, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(c.name,
                                      style: const TextStyle(
                                          color: HumanNodeTheme.textPrimary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                  if (c.isInteractive) ...[
                                    const SizedBox(width: 6),
                                    const Text('Interactive',
                                        style: TextStyle(color: HumanNodeTheme.textSecondary, fontSize: 11)),
                                  ],
                                  if (c.isNew) ...[
                                    const SizedBox(width: 6),
                                    const Text('New',
                                        style: TextStyle(color: HumanNodeTheme.primary, fontSize: 11)),
                                  ],
                                ],
                              ),
                              if (c.popularityRank > 0)
                                Text('#${c.popularityRank} most popular',
                                    style: const TextStyle(color: HumanNodeTheme.textSecondary, fontSize: 11)),
                              const SizedBox(height: 4),
                              Text(c.description,
                                  style: const TextStyle(color: HumanNodeTheme.textSecondary, fontSize: 12)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 34,
                          child: ElevatedButton(
                            onPressed: isConnecting
                                ? null
                                : () {
                                    setState(() => _connecting.add(c.id));
                                    Future.delayed(const Duration(milliseconds: 600), () {
                                      if (mounted) setState(() => _connecting.remove(c.id));
                                    });
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                            ),
                            child: isConnecting
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Connect', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : HumanNodeTheme.surfaceCard,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.black : HumanNodeTheme.textSecondary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
