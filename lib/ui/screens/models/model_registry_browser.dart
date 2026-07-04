import 'package:flutter/material.dart';
import 'model_download_sheet.dart';

class ModelRegistryItem {
  final String name;
  final String fileName;
  final String description;
  final String quantization;
  final String size;
  final String downloadUrl;
  final int sizeBytes;

  const ModelRegistryItem({
    required this.name,
    required this.fileName,
    required this.description,
    required this.quantization,
    required this.size,
    required this.downloadUrl,
    required this.sizeBytes,
  });
}

class ModelRegistryBrowser extends StatefulWidget {
  const ModelRegistryBrowser({super.key});
  @override
  State<ModelRegistryBrowser> createState() => _ModelRegistryBrowserState();
}

class _ModelRegistryBrowserState extends State<ModelRegistryBrowser> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  static const _catalog = [
    ModelRegistryItem(
      name: 'Qwen 2.5 1.5B Instruct',
      fileName: 'qwen2.5-1.5b-instruct-q4_k_m.gguf',
      description: 'Alibaba compact model, excellent for mobile. Best for everyday use.',
      quantization: 'Q4_K_M',
      size: '1.0 GB',
      downloadUrl: 'https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/qwen2.5-1.5b-instruct-q4_k_m.gguf',
      sizeBytes: 1000000000,
    ),
    ModelRegistryItem(
      name: 'Gemma 2 2B IT',
      fileName: 'gemma-2-2b-it-q4_k_m.gguf',
      description: 'Google lightweight model, fast and efficient on mobile.',
      quantization: 'Q4_K_M',
      size: '1.6 GB',
      downloadUrl: 'https://huggingface.co/bartowski/gemma-2-2b-it-GGUF/resolve/main/gemma-2-2b-it-Q4_K_M.gguf',
      sizeBytes: 1600000000,
    ),
    ModelRegistryItem(
      name: 'Llama 3.2 3B Instruct',
      fileName: 'llama-3.2-3b-instruct-q4_k_m.gguf',
      description: 'Meta lightweight general-purpose model, strong all-around.',
      quantization: 'Q4_K_M',
      size: '2.0 GB',
      downloadUrl: 'https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q4_K_M.gguf',
      sizeBytes: 2000000000,
    ),
    ModelRegistryItem(
      name: 'Phi-3 Mini 4K Instruct',
      fileName: 'phi-3-mini-4k-instruct-q4.gguf',
      description: 'Microsoft compact model, excellent reasoning for its size.',
      quantization: 'Q4_K_M',
      size: '2.2 GB',
      downloadUrl: 'https://huggingface.co/microsoft/Phi-3-mini-4k-instruct-gguf/resolve/main/Phi-3-mini-4k-instruct-q4.gguf',
      sizeBytes: 2200000000,
    ),
  ];

  List<ModelRegistryItem> get _filtered => _query.isEmpty
      ? _catalog
      : _catalog.where((m) => m.name.toLowerCase().contains(_query.toLowerCase())).toList();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(children: [
        Center(
          child: Container(
            width: 32, height: 4,
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
                color: cs.outlineVariant, borderRadius: BorderRadius.circular(2)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(children: [
            Text('Model Catalog',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search models...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filtered.length,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            itemBuilder: (ctx, i) {
              final item = _filtered[i];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(children: [
                    Container(
                      width: 46, height: 46,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [cs.primary, cs.tertiary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.smart_toy_rounded,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(item.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(item.description,
                            style: TextStyle(
                                fontSize: 11,
                                color: cs.onSurface.withAlpha(130)),
                            maxLines: 2),
                        const SizedBox(height: 4),
                        Row(children: [
                          _Tag(item.size),
                          const SizedBox(width: 6),
                          _Tag(item.quantization),
                        ]),
                      ]),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: cs.surface,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.vertical(top: Radius.circular(24))),
                          builder: (_) => ModelDownloadSheet(
                            modelName: item.name,
                            fileName: item.fileName,
                            downloadUrl: item.downloadUrl,
                            sizeBytes: item.sizeBytes,
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(60, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Get', style: TextStyle(fontSize: 13)),
                    ),
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag(this.label);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600, color: cs.primary)),
    );
  }
}
