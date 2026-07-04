import 'dart:math';
import 'llama_types.dart';

class Sampler {
  final int? seed;

  Sampler({this.seed});

  Random _getRandom() =>
      Random(seed ?? DateTime.now().microsecondsSinceEpoch);

  List<int> sample(List<double> logits, {LlamaSamplerParams? params}) {
    final p = params ?? const LlamaSamplerParams();
    final random = _getRandom();
    final penalized = _applyRepetitionPenalty(logits, p.repetitionPenalty);
    final topKResult = _applyTopK(penalized, p.topK);
    final topPResult = _applyTopP(topKResult, p.topP);
    final tempResult = _applyTemperature(topPResult, p.temperature);
    final probs = _softmax(tempResult);
    return [_categoricalSample(probs, random)];
  }

  List<int> sampleBatch(List<List<double>> logitsBatch,
          {LlamaSamplerParams? params}) =>
      logitsBatch.map((l) => sample(l, params: params).first).toList();

  List<double> _applyRepetitionPenalty(List<double> logits, double penalty) {
    if (penalty == 1.0) return logits;
    return logits.map((v) {
      if (v == double.negativeInfinity) return v;
      return v > 0 ? v / penalty : v * penalty;
    }).toList();
  }

  List<double> _applyTopK(List<double> logits, int k) {
    if (k <= 0 || k >= logits.length) return logits;
    final indexed = logits.asMap().entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final threshold = indexed[k - 1].value;
    return logits
        .map((v) => v >= threshold ? v : double.negativeInfinity)
        .toList();
  }

  List<double> _applyTopP(List<double> logits, double p) {
    if (p >= 1.0) return logits;
    if (p <= 0.0) return logits.map((_) => double.negativeInfinity).toList();
    final sorted = logits.asMap().entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final validEntries =
        sorted.where((e) => e.value != double.negativeInfinity).toList();
    if (validEntries.isEmpty) return logits;
    final maxLogit = validEntries.first.value;
    final totalSum =
        validEntries.fold(0.0, (sum, e) => sum + exp(e.value - maxLogit));
    double cumulative = 0;
    final topPIndices = <int>{};
    for (final entry in validEntries) {
      cumulative += exp(entry.value - maxLogit) / totalSum;
      topPIndices.add(entry.key);
      if (cumulative >= p) break;
    }
    return logits
        .asMap()
        .entries
        .map((e) =>
            topPIndices.contains(e.key) ? e.value : double.negativeInfinity)
        .toList();
  }

  List<double> _applyTemperature(List<double> logits, double temp) {
    final t = (temp <= 0 || temp.isNaN) ? 0.01 : temp;
    if (t == 1.0) return logits;
    return logits
        .map((v) => v == double.negativeInfinity ? v : v / t)
        .toList();
  }

  List<double> _softmax(List<double> xs) {
    final valid = xs.where((x) => x != double.negativeInfinity);
    if (valid.isEmpty) return xs.map((_) => 1.0 / xs.length).toList();
    final xMax = valid.reduce(max);
    final exps =
        xs.map((x) => x == double.negativeInfinity ? 0.0 : exp(x - xMax)).toList();
    final sum = exps.reduce((a, b) => a + b);
    if (sum == 0) return xs.map((_) => 1.0 / xs.length).toList();
    return exps.map((e) => e / sum).toList();
  }

  int _categoricalSample(List<double> probs, Random random) {
    final r = random.nextDouble();
    double cumulative = 0;
    for (int i = 0; i < probs.length; i++) {
      cumulative += probs[i];
      if (r <= cumulative) return i;
    }
    return probs.length - 1;
  }
}
