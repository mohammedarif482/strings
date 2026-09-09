import assert from 'node:assert';
import { db } from '../src/db/database.js';
import { CloudPredictionEngine } from '../src/services/predictionEngine.js';
import { PushDispatcher } from '../src/services/pushDispatcher.js';
import { simulationWorker } from '../src/services/simulationWorker.js';
import { getProtocolForPrediction } from '../src/services/contentLibrary.js';

async function runTests() {
  console.log('--- Running Aivo Backend & Cloud Simulation Tests ---');

  // Test 1: Database Seed Verification
  const alex = db.getUser('alex_01');
  const sarah = db.getUser('sarah_02');
  assert.ok(alex, 'Alex exists in cloud DB');
  assert.ok(sarah, 'Sarah exists in cloud DB');
  assert.strictEqual(alex.partnerId, 'sarah_02', 'Alex linked to Sarah');
  assert.strictEqual(sarah.partnerId, 'alex_01', 'Sarah linked to Alex');
  console.log('✓ Test 1 Passed: Relational couple data model initialized');

  // Test 2: Wearable simulation packet structure
  const testPacket = db.insertWearablePacket({
    userId: 'alex_01',
    hrv: 75.0,
    restingHR: 58,
    deepSleepRatio: 0.22,
    is_simulated: true,
  });
  assert.strictEqual(testPacket.is_simulated, true, 'Wearable packet marked is_simulated: true');
  assert.ok(testPacket.id, 'Packet has unique ID');
  console.log('✓ Test 2 Passed: Wearable packets persisted with is_simulated: true');

  // Test 3: Prediction Engine - Threshold Breach (> 0.70) Detection
  const checkinsSarah = [
    { moodScore: 3, stressScore: 9, energyLevel: 3, sleepHours: 5.8 },
    { moodScore: 4, stressScore: 8, energyLevel: 4, sleepHours: 6.0 },
    { moodScore: 3, stressScore: 9, energyLevel: 3, sleepHours: 6.1 },
  ];
  const sarahPrediction = CloudPredictionEngine.calculateState({
    userId: 'sarah_02',
    user: sarah,
    checkins: checkinsSarah,
    wearable: { hrv: 42, restingHR: 79, deepSleepRatio: 0.12 },
  });

  assert.ok(sarahPrediction.combinedStressIndex > 0.70, `CSI was ${sarahPrediction.combinedStressIndex}, expected > 0.70`);
  assert.strictEqual(sarahPrediction.isThresholdBreached, true, 'Threshold breach detected');
  assert.strictEqual(sarahPrediction.predictedState, 'High Stress / High Cortisol State');
  console.log('✓ Test 3 Passed: Combined Stress Index > 0.70 threshold breach detected');

  // Test 4: Server-Triggered Partner Nudge Dispatch
  const protocol = getProtocolForPrediction(sarahPrediction);
  const nudgeDispatch = await PushDispatcher.dispatchPartnerThresholdBreachNudge({
    targetUser: sarah,
    partnerUser: alex,
    prediction: sarahPrediction,
    protocol,
  });

  assert.ok(nudgeDispatch.nudgeId, 'Nudge record created');
  assert.ok(nudgeDispatch.deliveries.length > 0, 'Push notification delivered to Alex');
  assert.strictEqual(nudgeDispatch.deliveries[0].platform, 'ios');
  assert.ok(nudgeDispatch.deliveries[0].notificationPayload.notification.body.includes('Sarah'));
  console.log('✓ Test 4 Passed: Server-triggered partner push notification generated & delivered');

  // Test 5: Simulation Worker Tick Execution
  const tickResults = await simulationWorker.executeSimulationCycle();
  assert.ok(tickResults.length >= 2, 'Simulation generated packets for all users');
  const alexResult = tickResults.find(r => r.userId === 'alex_01');
  assert.ok(alexResult, 'Alex simulation result generated');
  console.log('✓ Test 5 Passed: 15-minute simulation cycle executed successfully');

  console.log('\n====================================================');
  console.log('🎉 ALL BACKEND TESTS PASSED SUCCESSFULLY (5/5)');
  console.log('====================================================\n');
}

runTests().catch((err) => {
  console.error('Test failed with error:', err);
  process.exit(1);
});
