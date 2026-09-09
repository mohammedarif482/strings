import { generateSyntheticWearablePacket } from './physiological.js';

const USERS = [
  { id: 'usr_alex', cycleDay: 10 },
  { id: 'usr_sarah', cycleDay: 24 }
];

console.log('[Cloud Simulator] Biometric Worker initialized.');
console.log('[Cloud Simulator] Simulating 15-minute cron queue execution...');

let cycleCount = 0;

function runSimulationCycle() {
  cycleCount++;
  const runId = `run_${Date.now()}`;
  console.log(`\n[Cloud Simulator] --- Simulation Cycle #${cycleCount} (Run ID: ${runId}) ---`);

  USERS.forEach(u => {
    const packet = generateSyntheticWearablePacket(u.id, u.cycleDay, runId);
    console.log(`[Telemetry Ingest] User: ${packet.user_id} | HRV: ${packet.hrv_ms}ms | RHR: ${packet.resting_hr}bpm | DeepSleep: ${packet.deep_sleep_minutes}m (is_simulated: ${packet.is_simulated})`);
  });
}

// Initial tick
runSimulationCycle();

// 15-minute interval (simulated every 60 seconds in dev mode for visibility)
const intervalMs = process.env.NODE_ENV === 'production' ? 15 * 60 * 1000 : 60 * 1000;
setInterval(runSimulationCycle, intervalMs);
