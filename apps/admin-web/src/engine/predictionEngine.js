/**
 * Pure deterministic rule-based calculation function.
 * Computes a biological and stress forecast from check-ins, wearables, and cycle day.
 */
export function calculatePredictedState({
  userId,
  date = new Date(),
  checkins = [],
  wearable = { hrv: 65, restingHR: 62, deepSleepRatio: 0.20 },
  cycleDay = 12,
}) {
  // 1. Cycle Phase Calculation
  let cyclePhase = 'follicular';
  if (cycleDay >= 1 && cycleDay <= 5) cyclePhase = 'menstrual';
  else if (cycleDay >= 6 && cycleDay <= 13) cyclePhase = 'follicular';
  else if (cycleDay === 14) cyclePhase = 'ovulatory';
  else cyclePhase = 'luteal';

  // Assign Luteal (especially days 21-28) higher baseline weight for cortisol/stress (+0.35 modifier)
  let cycleModifier = 0.0;
  if (cycleDay >= 21 && cycleDay <= 28) {
    cycleModifier = 1.0; // Full 0.35 contribution
  } else if (cycleDay >= 15 && cycleDay < 21) {
    cycleModifier = 0.45;
  } else if (cycleDay >= 1 && cycleDay <= 5) {
    cycleModifier = 0.30;
  } else {
    cycleModifier = 0.0;
  }

  // 2. Trend Aggregation (3-day rolling averages)
  const sorted = [...checkins].sort((a, b) => new Date(b.date) - new Date(a.date));
  const recent = sorted.slice(0, 3);

  let rollingStressAvg = 4.0;
  let rollingMoodAvg = 7.0;
  let rollingSleepAvg = 7.5;

  if (recent.length > 0) {
    rollingStressAvg = recent.reduce((sum, c) => sum + c.stressScore, 0) / recent.length;
    rollingMoodAvg = recent.reduce((sum, c) => sum + c.moodScore, 0) / recent.length;
    rollingSleepAvg = recent.reduce((sum, c) => sum + c.sleepHours, 0) / recent.length;
  }

  // Sleep debt modifier: IF 3-day avg sleep < 7 hours, add +0.25 to predicted stress risk
  let sleepDebtModifier = 0.0;
  if (rollingSleepAvg < 7.0) {
    sleepDebtModifier = 1.0; // Full 0.25 contribution
  }

  // 3. Weighted Scoring Engine (Weights sum to 1.0: 0.35 + 0.40 + 0.25)
  const normalizedStress = Math.min(1.0, Math.max(0.0, rollingStressAvg / 10.0));

  // Combined Stress Index = (Cycle Modifier * 0.35) + (3-Day Avg Stress * 0.40) + (Sleep Debt Modifier * 0.25)
  const combinedStressIndex =
    (cycleModifier * 0.35) +
    (normalizedStress * 0.40) +
    (sleepDebtModifier * 0.25);

  const confidenceScore = Math.min(0.98, Math.max(0.70,
    0.82 + (recent.length >= 3 ? 0.08 : 0.04) + (wearable.hrv > 50 ? 0.05 : 0.02)
  ));

  // 4. Output Generator: State Evaluation & Primary Driver
  let predictedState;
  let primaryDriver;
  let suggestedActionTag;

  if (combinedStressIndex > 0.65) {
    predictedState = "High Stress / High Cortisol State";
    const drivers = [];
    if (cycleDay >= 21) drivers.add ? drivers.push(`Late Luteal Cortisol Spike (Day ${cycleDay})`) : null;
    if (sleepDebtModifier > 0) drivers.push(`3-Day Sleep Debt (${rollingSleepAvg.toFixed(1)}h avg)`);
    if (normalizedStress > 0.5) drivers.push(`Elevated Self-Reported Tension (${rollingStressAvg.toFixed(1)}/10)`);
    if (drivers.length === 0) drivers.push("Combined Neuroendocrine Vulnerability");

    primaryDriver = drivers.join(" + ");
    suggestedActionTag = "Cortisol Reset & Somatic Breathing";
  } else if (combinedStressIndex > 0.40 && rollingMoodAvg < 5.0) {
    predictedState = "Low Energy / Emotional Vulnerability";
    primaryDriver = `Sub-Optimal Mood Recovery (${rollingMoodAvg.toFixed(1)}/10) during ${cyclePhase.toUpperCase()} Phase`;
    suggestedActionTag = "Gentle Restorative Flow";
  } else {
    predictedState = "Balanced / Peak Recovery State";
    primaryDriver = `High Parasympathetic Tone (HRV ${Math.round(wearable.hrv)}ms) & Restorative Sleep (${rollingSleepAvg.toFixed(1)}h avg)`;
    suggestedActionTag = "Mindful Focus & Vitality Check-in";
  }

  return {
    userId,
    date,
    predictedState,
    confidenceScore: parseFloat(confidenceScore.toFixed(2)),
    primaryDriver,
    suggestedActionTag,
    cyclePhase,
    cycleDay,
    combinedStressIndex: parseFloat(combinedStressIndex.toFixed(3)),
    rollingStressAvg: parseFloat(rollingStressAvg.toFixed(1)),
    rollingMoodAvg: parseFloat(rollingMoodAvg.toFixed(1)),
    rollingSleepAvg: parseFloat(rollingSleepAvg.toFixed(1)),
  };
}
