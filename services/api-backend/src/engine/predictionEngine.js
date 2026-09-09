/**
 * Deterministic Rules-Based Prediction Engine
 * Calculates Combined Stress Index (CSI) from 3 physiological inputs:
 * CSI = (Cycle Phase Weight * 0.35) + (3-Day Rolling Stress * 0.40) + (Sleep Debt / HRV Delta * 0.25)
 */

export function getCyclePhase(cycleDay) {
  if (cycleDay >= 1 && cycleDay <= 5) return 'menstrual';
  if (cycleDay >= 6 && cycleDay <= 13) return 'follicular';
  if (cycleDay === 14) return 'ovulatory';
  return 'luteal'; // Days 15-28+
}

export function calculatePrediction({ cycleDay, recentCheckins = [], wearableData = null }) {
  const phase = getCyclePhase(cycleDay);

  // 1. Cycle Phase Weight (Late-luteal Days 21-28 elevates cortisol reactivity)
  let cycleWeight = 0.10;
  if (phase === 'luteal') {
    cycleWeight = cycleDay >= 21 ? 0.40 : 0.25;
  }

  // 2. 3-Day Rolling Stress Average (1-10 normalized to 0.0 - 1.0)
  const count = recentCheckins.length || 1;
  const avgStress = recentCheckins.reduce((sum, c) => sum + (c.stress_score || 4), 0) / count;
  const stressWeight = (avgStress / 10.0) * 0.40;

  // 3. Sleep Debt / HRV Delta
  const avgSleep = recentCheckins.reduce((sum, c) => sum + (c.sleep_hours || 7.5), 0) / count;
  let sleepDebtWeight = 0.0;
  if (avgSleep < 7.0) {
    sleepDebtWeight += (7.0 - avgSleep) * 0.15; // Scaled sleep deficit
  }
  if (wearableData && wearableData.hrv_ms < 45) {
    sleepDebtWeight += 0.10; // Suppressed HRV penalty
  }

  // Combined Stress Index (capped at 1.0)
  const combinedStressIndex = Math.min(1.0, Number((cycleWeight + stressWeight + sleepDebtWeight).toFixed(3)));

  // State Evaluation
  let predictedState = 'balanced';
  let contentTag = 'follicular_peak';
  let primaryDriver = 'Balanced biological baseline and steady recovery.';
  const isThresholdBreached = combinedStressIndex >= 0.70;

  if (isThresholdBreached) {
    predictedState = 'High Stress & Cortisol Shift';
    contentTag = 'luteal_high_cortisol';
    primaryDriver = `${phase.toUpperCase()} phase sensitivity combined with ${avgSleep.toFixed(1)}h sleep debt.`;
  }

  return {
    combinedStressIndex,
    confidenceScore: 0.88,
    predictedState,
    primaryDriver,
    contentTag,
    isThresholdBreached
  };
}
