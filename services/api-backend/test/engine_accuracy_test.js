import test from 'node:test';
import assert from 'node:assert/strict';
import { CloudPredictionEngine } from '../src/services/predictionEngine.js';

// Box-Muller transform to generate standard normal Gaussian noise
function generateGaussianNoise(mean = 0, stdDev = 1) {
  let u1 = Math.random();
  let u2 = Math.random();
  while (u1 === 0) u1 = Math.random();
  const z0 = Math.sqrt(-2.0 * Math.log(u1)) * Math.cos(2.0 * Math.PI * u2);
  return mean + z0 * stdDev;
}

test('Pattern Recovery Test: Inject 28-day profile with late-luteal cortisol spike (Days 22-26)', () => {
  const user = {
    id: 'eval_user_28d',
    name: 'Validation Subject',
    cycleStartDate: new Date('2026-08-01T00:00:00.000Z'),
    averageCycleLength: 28,
  };

  // Build 28-day synthetic history
  // Days 1-21: Baseline low stress (2-3), optimal sleep (7.8-8.2h), healthy HRV (72-80ms)
  // Days 22-26: Injected acute late-luteal spike (stress 8-9, sleep <6h deficit: 5.2h, HRV 45ms)
  // Days 27-28: Menstrual transition unwind
  const dailyHistory = [];
  for (let day = 1; day <= 28; day++) {
    const isSpike = day >= 22 && day <= 26;
    dailyHistory.push({
      day,
      date: new Date(new Date('2026-08-01T00:00:00.000Z').getTime() + (day - 1) * 86400000),
      checkin: {
        userId: user.id,
        moodScore: isSpike ? 3 : 8,
        stressScore: isSpike ? 8.5 : 2.5,
        energyLevel: isSpike ? 3.5 : 8.0,
        sleepHours: isSpike ? 5.2 : 8.0,
      },
      wearable: {
        hrv: isSpike ? 46.0 : 76.0,
        restingHR: isSpike ? 74 : 58,
        deepSleepRatio: isSpike ? 0.12 : 0.24,
      },
    });
  }

  // Evaluate engine predictions across Days 23-26 (allowing 3-day rolling window to aggregate)
  for (let targetDay = 23; targetDay <= 26; targetDay++) {
    const dayItem = dailyHistory.find((d) => d.day === targetDay);
    // Grab past 3 days of checkins up to current day
    const pastCheckins = dailyHistory
      .filter((d) => d.day <= targetDay)
      .slice(-3)
      .reverse()
      .map((d) => d.checkin);

    const prediction = CloudPredictionEngine.calculateState({
      userId: user.id,
      user,
      checkins: pastCheckins,
      wearable: dayItem.wearable,
      date: dayItem.date,
    });

    // Assertions
    assert.equal(
      prediction.predictedState,
      'High Stress / High Cortisol State',
      `Day ${targetDay} must trigger High Stress / High Cortisol State`
    );
    assert.ok(
      prediction.confidenceScore > 0.75,
      `Day ${targetDay} confidence score (${prediction.confidenceScore}) must exceed 0.75`
    );
    assert.ok(
      prediction.combinedStressIndex > 0.70,
      `Day ${targetDay} Combined Stress Index (${prediction.combinedStressIndex}) must breach 0.70`
    );
    assert.equal(
      prediction.isThresholdBreached,
      true,
      `Day ${targetDay} must flag isThresholdBreached = true`
    );
    assert.match(
      prediction.primaryDriver,
      /Late Luteal Cortisol Spike/,
      `Day ${targetDay} driver must identify late luteal spike`
    );
  }
});

test('Noise Degradation Test: 1,000 Simulated Cycles with Gaussian Noise (±15% variance)', () => {
  const totalCycles = 1000;
  let truePositives = 0;
  let falseNegatives = 0;
  let trueNegatives = 0;
  let falsePositives = 0;

  const baseUser = {
    id: 'monte_carlo_user',
    name: 'Monte Carlo Subject',
    cycleStartDate: new Date('2026-08-01T00:00:00.000Z'),
    averageCycleLength: 28,
  };

  for (let cycle = 0; cycle < totalCycles; cycle++) {
    // Condition A: High-Stress Ground Truth (Late luteal Day 24, sleep deficit, high stress)
    {
      const cycleDate = new Date(new Date('2026-08-01T00:00:00.000Z').getTime() + 23 * 86400000); // Day 24
      // Inject ±15% Gaussian noise
      const noisySleep = Math.max(3.0, Math.min(10.0, 5.5 + generateGaussianNoise(0, 0.4)));
      const noisyStress = Math.max(1, Math.min(10, Math.round(8.0 + generateGaussianNoise(0, 0.6))));
      const noisyHrv = Math.max(25, 48.0 * (1 + generateGaussianNoise(0, 0.08)));

      const checkins = [
        { moodScore: 4, stressScore: noisyStress, energyLevel: 4, sleepHours: noisySleep },
        { moodScore: 4, stressScore: noisyStress, energyLevel: 4, sleepHours: noisySleep },
        { moodScore: 4, stressScore: noisyStress, energyLevel: 4, sleepHours: noisySleep },
      ];

      const prediction = CloudPredictionEngine.calculateState({
        userId: baseUser.id,
        user: baseUser,
        checkins,
        wearable: { hrv: noisyHrv, restingHR: 75, deepSleepRatio: 0.14 },
        date: cycleDate,
      });

      if (prediction.isThresholdBreached && prediction.predictedState === 'High Stress / High Cortisol State') {
        truePositives++;
      } else {
        falseNegatives++;
      }
    }

    // Condition B: Calm / Balanced Ground Truth (Follicular Day 9, optimal sleep >7.5h, low stress <=3)
    {
      const cycleDate = new Date(new Date('2026-08-01T00:00:00.000Z').getTime() + 8 * 86400000); // Day 9
      const noisySleep = Math.max(6.0, 8.0 + generateGaussianNoise(0, 0.3));
      const noisyStress = Math.max(1, Math.min(5, Math.round(2.5 + generateGaussianNoise(0, 0.5))));
      const noisyHrv = Math.max(40, 75.0 * (1 + generateGaussianNoise(0, 0.08)));

      const checkins = [
        { moodScore: 8, stressScore: noisyStress, energyLevel: 8, sleepHours: noisySleep },
        { moodScore: 8, stressScore: noisyStress, energyLevel: 8, sleepHours: noisySleep },
        { moodScore: 8, stressScore: noisyStress, energyLevel: 8, sleepHours: noisySleep },
      ];

      const prediction = CloudPredictionEngine.calculateState({
        userId: baseUser.id,
        user: baseUser,
        checkins,
        wearable: { hrv: noisyHrv, restingHR: 56, deepSleepRatio: 0.25 },
        date: cycleDate,
      });

      if (!prediction.isThresholdBreached && prediction.predictedState !== 'High Stress / High Cortisol State') {
        trueNegatives++;
      } else {
        falsePositives++;
      }
    }
  }

  // Calculate Statistical Metrics
  const sensitivity = (truePositives / (truePositives + falseNegatives)) * 100;
  const specificity = (trueNegatives / (trueNegatives + falsePositives)) * 100;
  const falsePositiveRate = (falsePositives / (trueNegatives + falsePositives)) * 100;

  console.log(`\n======================================================`);
  console.log(`📊 MONTE CARLO VALIDATION RESULTS (1,000 CYCLES):`);
  console.log(`------------------------------------------------------`);
  console.log(`• True Positives (TP):  ${truePositives} / ${totalCycles}`);
  console.log(`• False Negatives (FN): ${falseNegatives} / ${totalCycles}`);
  console.log(`• True Negatives (TN):  ${trueNegatives} / ${totalCycles}`);
  console.log(`• False Positives (FP): ${falsePositives} / ${totalCycles}`);
  console.log(`• Sensitivity (Recall): ${sensitivity.toFixed(2)}% (Target: >= 90%)`);
  console.log(`• Specificity:          ${specificity.toFixed(2)}% (Target: >= 92%)`);
  console.log(`• False Positive Rate:  ${falsePositiveRate.toFixed(2)}% (Target: <= 8%)`);
  console.log(`======================================================\n`);

  // Assert target quality thresholds
  assert.ok(sensitivity >= 90.0, `Sensitivity (${sensitivity.toFixed(2)}%) must be >= 90%`);
  assert.ok(specificity >= 92.0, `Specificity (${specificity.toFixed(2)}%) must be >= 92%`);
  assert.ok(falsePositiveRate <= 8.0, `False positive rate (${falsePositiveRate.toFixed(2)}%) must be <= 8%`);
});
