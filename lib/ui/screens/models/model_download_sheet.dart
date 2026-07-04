import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:tern/core/di/service_locator.dart';
import 'package:tern/providers/models_provider.dart';

class ModelDownloadSheet extends ConsumerStatefulWidget {
  final String modelName;
  final String fileName;
  final String downloadUrl;
  final int sizeBytes;

  const ModelDownloadSheet({
    super.key,
    required this.modelName,
    required this.fileName,
    required this.downloadUrl,
    required this.sizeBytes,
  });

  @override
  ConsumerState<ModelDownloadSheet> createState() => _ModelDownloadSheetState();
}

class _ModelDownloadSheetState extends ConsumerState<ModelDownloadSheet> {
  double _progress = 0;
  bool _downloading = false;
  bool _completed = false;
  String? _error;
  http.Client? _client;

  Future<void> _startDownload() async {
    if (widget.downloadUrl.isEmpty) {
      setState(() => _error = 'No download URL configured for this model.');
      return;
    }

    setState(() {
      _downloading = true;
      _error = null;
      _progress = 0;
    });

    try {
      final path = await ServiceLocator.fileCache.getModelPath(widget.fileName);
      final file = File(path);

      _client = http.Client();
      final request = http.Request('GET', Uri.parse(widget.downloadUrl));
      final response = await _client!.send(request);

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final total = response.contentLength ?? widget.sizeBytes;
      int received = 0;
      final sink = file.openWrite();

      await for (final chunk in response.stream) {
        if (!_downloading) {
          await sink.close();
          await file.delete();
          return;
        }
        sink.add(chunk);
        received += chunk.length;
        if (mounted) {
          setState(() => _progress = total > 0 ? received / total : 0);
        }
      }

      await sink.close();

      if (mounted) {
        setState(() {
          _downloading = false;
          _completed = true;
        });
        ref.read(modelsProvider.notifier).refresh();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _downloading = false;
          _error = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      _client?.close();
      _client = null;
    }
  }

  void _cancel() {
    _client?.close();
    _client = null;
    setState(() {
      _downloading = false;
      _progress = 0;
    });
  }

  @override
  void dispose() {
    _client?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sizeGB = widget.sizeBytes / (1024 * 1024 * 1024);
    final receivedGB = sizeGB * _progress;

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(
            child: Container(
              width: 32, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Row(children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [cs.primary, cs.tertiary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Download ${widget.modelName}',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('${sizeGB.toStringAsFixed(1)} GB · Q4_K_M',
                    style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurface.withAlpha(120))),
              ]),
            ),
          ]),
          const SizedBox(height: 24),
          if (_completed) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(20),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: Colors.green.withAlpha(60)),
              ),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.green, size: 28),
                const SizedBox(width: 12),
                Text('Download complete!',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.green.shade700)),
              ]),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Done'),
            ),
          ] else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _downloading ? _progress : 0,
                minHeight: 10,
                backgroundColor: cs.surfaceContainerHighest,
                valueColor:
                    AlwaysStoppedAnimation<Color>(cs.primary),
              ),
            ),
            const SizedBox(height: 10),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              Text(
                _downloading
                    ? '${(_progress * 100).toStringAsFixed(0)}%'
                    : '0%',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: cs.primary),
              ),
              Text(
                _downloading
                    ? '${receivedGB.toStringAsFixed(2)} GB of ${sizeGB.toStringAsFixed(1)} GB'
                    : '0.0 GB of ${sizeGB.toStringAsFixed(1)} GB',
                style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withAlpha(120)),
              ),
            ]),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.errorContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(_error!,
                    style: TextStyle(
                        color: cs.onErrorContainer, fontSize: 12)),
              ),
            ],
            const SizedBox(height: 20),
            if (_downloading)
              OutlinedButton(
                onPressed: _cancel,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Cancel'),
              )
            else
              FilledButton.icon(
                onPressed: _startDownload,
                icon: const Icon(Icons.download_rounded),
                label: Text(_error != null ? 'Retry Download' : 'Download'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
          ],
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}
