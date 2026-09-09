class Prediction {
  final String predictedState;
  final double combinedStressIndex;
  final double confidenceScore;
  final String primaryDriver;
  final String contentTag;
  final bool isThresholdBreached;

  Prediction({
    required this.predictedState,
    required this.combinedStressIndex,
    required this.confidenceScore,
    required this.primaryDriver,
    required this.contentTag,
    required this.isThresholdBreached,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      predictedState: json['predictedState'] ?? 'Balanced',
      combinedStressIndex: (json['combinedStressIndex'] as num?)?.toDouble() ?? 0.35,
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.85,
      primaryDriver: json['primaryDriver'] ?? 'Balanced baseline',
      contentTag: json['contentTag'] ?? 'follicular_peak',
      isThresholdBreached: json['isThresholdBreached'] ?? false,
    );
  }
}
