import '../models/prediction_models.dart';

class PredictionEngine {
  /// Pure deterministic rule-based calculation function.
  /// No machine learning, 100% explainable and traceable.
  static PredictionResult calculatePredictedState({
    required String userId,
    required DateTime date,
    required List<DailyCheckin> checkins,
    required WearableData wearable,
    required int cycleDay,
  }) {
    // 1. Cycle Phase Calculation
    final cyclePhase = getCyclePhase(cycleDay);
    
    // Assign Luteal (especially days 21-28) higher baseline weight for cortisol/stress (+0.35 modifier)
    double cycleModifier = 0.0;
    if (cycleDay >= 21 && cycleDay <= 28) {
      cycleModifier = 1.0; // Late luteal: full 0.35 contribution
    } else if (cycleDay >= 15 && cycleDay < 21) {
      cycleModifier = 0.45; // Early luteal
    } else if (cycleDay >= 1 && cycleDay <= 5) {
      cycleModifier = 0.30; // Menstrual
    } else {
      cycleModifier = 0.0; // Follicular / Ovulatory
    }

    // 2. Trend Aggregation (3-Day Rolling Averages)
    final sortedCheckins = List<DailyCheckin>.from(checkins)
      ..sort((a, b) => b.date.compareTo(a.date));
    
    final recentCheckins = sortedCheckins.take(3).toList();

    double rollingStressAvg = 4.0;
    double rollingMoodAvg = 7.0;
    double rollingSleepAvg = 7.5;

    if (recentCheckins.isNotEmpty) {
      rollingStressAvg = recentCheckins.map((c) => c.stressScore).reduce((a, b) => a + b) / recentCheckins.length;
      rollingMoodAvg = recentCheckins.map((c) => c.moodScore).reduce((a, b) => a + b) / recentCheckins.length;
      rollingSleepAvg = recentCheckins.map((c) => c.sleepHours).reduce((a, b) => a + b) / recentCheckins.length;
    }

    // Calculate sleep debt: IF 3-day avg sleep < 7 hours, add +0.25 to predicted stress risk
    double sleepDebtModifier = 0.0;
    if (rollingSleepAvg < 7.0) {
      sleepDebtModifier = 1.0; // Full 0.25 contribution
    }

    // 3. Weighted Scoring Engine (Weights sum to 1.0: 0.35 + 0.40 + 0.25)
    final double normalizedStress = (rollingStressAvg / 10.0).clamp(0.0, 1.0);

    // Combined Stress Index = (Cycle Modifier * 0.35) + (3-Day Avg Stress * 0.40) + (Sleep Debt Modifier * 0.25)
    final double combinedStressIndex = (cycleModifier * 0.35) +
        (normalizedStress * 0.40) +
        (sleepDebtModifier * 0.25);

    // Wearable telemetry confidence calculation
    final double confidenceScore = (0.82 + (recentCheckins.length >= 3 ? 0.08 : 0.04) + (wearable.hrv > 50 ? 0.05 : 0.02)).clamp(0.70, 0.98);

    // 4. Output Generator: State Evaluation & Primary Driver
    String predictedState;
    String primaryDriver;
    String suggestedActionTag;

    if (combinedStressIndex > 0.65) {
      predictedState = "High Stress / High Cortisol State";
      
      final List<String> drivers = [];
      if (cycleDay >= 21) {
        drivers.add("Late Luteal Cortisol Spike (Day $cycleDay)");
      }
      if (sleepDebtModifier > 0) {
        drivers.add("3-Day Sleep Debt (${rollingSleepAvg.toStringAsFixed(1)}h avg)");
      }
      if (normalizedStress > 0.5) {
        drivers.add("Elevated Tension (${rollingStressAvg.toStringAsFixed(1)}/10)");
      }
      if (drivers.isEmpty) drivers.add("Elevated Neuroendocrine Vulnerability");

      primaryDriver = drivers.join(" + ");
      suggestedActionTag = "Cortisol Reset & Somatic Breathing";
    } else if (combinedStressIndex > 0.40 && rollingMoodAvg < 5.0) {
      predictedState = "Low Energy / Emotional Vulnerability";
      primaryDriver = "Sub-Optimal Mood Recovery (${rollingMoodAvg.toStringAsFixed(1)}/10) during ${getPhaseName(cyclePhase)} Phase";
      suggestedActionTag = "Gentle Restorative Flow";
    } else {
      predictedState = "Balanced / Peak Recovery State";
      primaryDriver = "High Parasympathetic Tone (HRV ${wearable.hrv.toInt()}ms) & Restorative Sleep (${rollingSleepAvg.toStringAsFixed(1)}h avg)";
      suggestedActionTag = "Mindful Focus & Vitality Check-in";
    }

    return PredictionResult(
      userId: userId,
      date: date,
      predictedState: predictedState,
      confidenceScore: double.parse(confidenceScore.toStringAsFixed(2)),
      primaryDriver: primaryDriver,
      suggestedActionTag: suggestedActionTag,
      cyclePhase: cyclePhase,
      cycleDay: cycleDay,
      combinedStressIndex: double.parse(combinedStressIndex.toStringAsFixed(3)),
      rollingStressAvg: double.parse(rollingStressAvg.toStringAsFixed(1)),
      rollingMoodAvg: double.parse(rollingMoodAvg.toStringAsFixed(1)),
      rollingSleepAvg: double.parse(rollingSleepAvg.toStringAsFixed(1)),
    );
  }

  static CyclePhase getCyclePhase(int cycleDay) {
    if (cycleDay >= 1 && cycleDay <= 5) return CyclePhase.menstrual;
    if (cycleDay >= 6 && cycleDay <= 13) return CyclePhase.follicular;
    if (cycleDay == 14) return CyclePhase.ovulatory;
    return CyclePhase.luteal;
  }

  static String getPhaseName(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual: return "Menstrual";
      case CyclePhase.follicular: return "Follicular";
      case CyclePhase.ovulatory: return "Ovulatory";
      case CyclePhase.luteal: return "Luteal";
    }
  }
}
