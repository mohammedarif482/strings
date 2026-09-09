import test from 'node:test';
import assert from 'node:assert/strict';
import { db } from '../src/db/database.js';
import { CloudPredictionEngine } from '../src/services/predictionEngine.js';
import { getProtocolForPrediction, formatTemplate } from '../src/services/contentLibrary.js';
import { PushDispatcher } from '../src/services/pushDispatcher.js';

test('End-to-End Partner Nudge: Trigger & FCM Delivery Flow', async () => {
  // 1. Mock two paired accounts
  const userA = db.createUser({
    name: 'Jordan Rivera',
    email: 'jordan@aivo.health',
    password: 'securePassword123',
    cycleStartDate: new Date(Date.now() - 23 * 86400000), // Day 24 (late luteal)
    averageCycleLength: 28,
  });

  const userB = db.createUser({
    name: 'Taylor Cole',
    email: 'taylor@aivo.health',
    password: 'securePassword456',
    cycleStartDate: new Date(Date.now() - 10 * 86400000),
    averageCycleLength: 28,
  });

  // Pair accounts
  userA.partnerId = userB.id;
  userB.partnerId = userA.id;

  // Register User B FCM device token
  db.registerDeviceToken(userB.id, 'fcm_token_taylor_device_xyz', 'ios');

  // 2. Inject high-stress biometrics for User A breaching threshold (>0.70)
  const stressCheckins = [
    { userId: userA.id, moodScore: 3, stressScore: 9, energyLevel: 3, sleepHours: 5.5 },
    { userId: userA.id, moodScore: 4, stressScore: 8, energyLevel: 4, sleepHours: 5.8 },
    { userId: userA.id, moodScore: 4, stressScore: 8, energyLevel: 4, sleepHours: 6.0 },
  ];

  const wearablePacket = {
    userId: userA.id,
    hrv: 44.0,
    restingHR: 76,
    deepSleepRatio: 0.12,
  };

  const prediction = CloudPredictionEngine.calculateState({
    userId: userA.id,
    user: userA,
    checkins: stressCheckins,
    wearable: wearablePacket,
  });

  assert.ok(prediction.isThresholdBreached, 'Threshold must be breached for injected biometrics');
  assert.ok(prediction.combinedStressIndex > 0.70, `Combined Stress Index (${prediction.combinedStressIndex}) must breach 0.70`);

  const protocol = getProtocolForPrediction(prediction);
  assert.ok(protocol.title, 'Matching protocol must be resolved');
  assert.ok(protocol.actionTipForUser, 'Action tip must be defined');

  // 3. Dispatch partner threshold breach nudge
  const breachResult = await PushDispatcher.dispatchPartnerThresholdBreachNudge({
    targetUser: userA,
    partnerUser: userB,
    prediction,
    protocol,
  });

  assert.ok(breachResult.success, 'Nudge dispatch must succeed');
  assert.ok(breachResult.nudgeId, 'Nudge record ID must be generated');

  // 4. Assert database persistence in nudges table
  const partnerNudges = db.getNudgesForUser(userB.id);
  const found = partnerNudges.find((n) => n.id === breachResult.nudgeId);
  assert.ok(found, 'Nudge must be saved in database');
  assert.equal(found.senderId, userA.id, 'Sender ID must match User A');
  assert.equal(found.recipientId, userB.id, 'Recipient ID must match User B');

  // 5. Assert Mock FCM payload construction
  assert.ok(breachResult.fcmNotification, 'FCM notification payload must exist');
  assert.match(breachResult.fcmNotification.title, /Heads up about Jordan Rivera/i);
  assert.match(breachResult.fcmNotification.body, /high-cortisol|sleep debt/i);
});

test('End-to-End Partner Nudge: Feedback Loop & Metrics Aggregation Assertion', async () => {
  // 1. Create test nudge
  const nudge = db.saveNudge({
    senderId: 'user_alex',
    recipientId: 'user_sarah',
    message: 'Sarah is entering high-cortisol window tomorrow.',
    suggestedSupport: 'Prepare dinner and lower friction',
  });

  assert.equal(nudge.was_helpful, null);

  // 2. Simulate User B submitting was_helpful: true and tap-back reaction
  const updated = db.updateNudgeFeedback(nudge.id, true, "I've got dinner covered tonight ❤️");
  assert.equal(updated.was_helpful, true);
  assert.equal(updated.supportReaction, "I've got dinner covered tonight ❤️");

  // 3. Verify feedback aggregation metrics
  const metrics = db.getNudgesMetrics();
  assert.ok(metrics.totalNudgesSent >= 1);
  assert.ok(metrics.totalFeedbackReceived >= 1);
  assert.ok(metrics.helpfulCount >= 1);
  assert.ok(metrics.reactionsDelivered >= 1);
  assert.ok(metrics.helpfulnessRatio > 0.5);
  assert.ok(metrics.algorithmAccuracyPercentage >= 50.0);
});
