/**
 * Physiological Telemetry & Hormonal Noise Curve Models
 */

export function generateSyntheticWearablePacket(userId, cycleDay, runId) {
  // Base biological metrics
  let baseHRV = 55;
  let baseRHR = 62;
  let deepSleep = 90;

  // Luteal phase variance (Days 15-28, late luteal 21-28)
  if (cycleDay >= 21 && cycleDay <= 28) {
    baseHRV -= 15;   // Marked drop in HRV during late luteal
    baseRHR += 6;    // Mild RHR elevation
    deepSleep -= 25; // Sleep fragmentation
  } else if (cycleDay >= 15) {
    baseHRV -= 6;
    baseRHR += 2;
  } else if (cycleDay >= 6 && cycleDay <= 13) {
    baseHRV += 10;   // Follicular resilience
    baseRHR -= 3;
    deepSleep += 15;
  }

  // Realistic Gaussian noise
  const noise = (Math.random() - 0.5) * 8;

  return {
    user_id: userId,
    timestamp: new Date().toISOString(),
    hrv_ms: Math.max(20, Math.round(baseHRV + noise)),
    resting_hr: Math.round(baseRHR + (noise * 0.5)),
    deep_sleep_minutes: Math.max(30, Math.round(deepSleep + noise * 2)),
    is_simulated: true,
    simulation_run_id: runId
  };
}
