class TokenCounter {
  static int estimate(String text) => text.isEmpty ? 0 : (text.length / 3.5).ceil();
  static int estimateBatch(List<String> texts) => texts.fold(0, (sum, t) => sum + estimate(t));
  static int contextTokens(int modelParams, {int overhead = 256}) => (modelParams * 2.1).ceil() + overhead;
}
