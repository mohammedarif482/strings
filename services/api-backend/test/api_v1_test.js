import test from 'node:test';
import assert from 'node:assert/strict';
import { db } from '../src/db/database.js';

test('REST API: User Registration and Profile update', () => {
  const newUser = db.createUser({
    name: 'Elena Rostova',
    email: 'elena@aivo.health',
    password: 'secret_password_123',
    cycleStartDate: '2026-08-20',
    averageCycleLength: 29,
    timezone: 'America/New_York',
  });

  assert.ok(newUser.id);
  assert.equal(newUser.name, 'Elena Rostova');
  assert.equal(newUser.email, 'elena@aivo.health');
  assert.equal(newUser.averageCycleLength, 29);

  // Test duplicate email prevention
  assert.throws(() => {
    db.createUser({
      name: 'Duplicate Elena',
      email: 'elena@aivo.health',
      password: 'another_password',
    });
  }, /already exists/);

  // Test profile update
  const updated = db.updateUserProfile(newUser.id, {
    name: 'Elena Rostova-Cole',
    averageCycleLength: 30,
  });
  assert.equal(updated.name, 'Elena Rostova-Cole');
  assert.equal(updated.averageCycleLength, 30);
});

test('REST API: Wearable Stream Ingestion', () => {
  const packet = db.insertWearablePacket({
    userId: 'alex_01',
    hrv: 72,
    restingHR: 61,
    deepSleepRatio: 0.25,
    is_simulated: false,
    simulation_run_id: 'real_device_pull_01',
  });

  assert.ok(packet.id);
  assert.equal(packet.userId, 'alex_01');
  assert.equal(packet.hrv, 72);
  assert.equal(packet.restingHR, 61);
  assert.equal(packet.is_simulated, false);
});

test('REST API: Predictions Today and Historical Trend', () => {
  const history = db.getPredictionHistory('alex_01', 14);
  assert.equal(history.length, 14);
  assert.ok(history[0].date);
  assert.ok(history[0].cyclePhase);
  assert.ok(history[0].wellnessScore >= 45 && history[0].wellnessScore <= 99);
});

test('REST API: Partner Invite, Accept, and Status Privacy Filter', () => {
  // 1. Create invite
  const invite = db.createPartnerInvite('alex_01');
  assert.equal(invite.code.length, 6);
  assert.equal(invite.status, 'active');

  // 2. Accept invite as Sarah
  db.unlinkPartner('alex_01');
  const redeemResult = db.redeemPartnerInvite('sarah_02', invite.code);
  assert.equal(redeemResult.success, true);
  assert.equal(db.getUser('alex_01').partnerId, 'sarah_02');

  // 3. Privacy bounds check on partner status
  const privacy = db.getPrivacySettings('sarah_02');
  assert.equal(privacy.shareCyclePhaseDetails, false);
  assert.equal(privacy.shareDailyCheckinScores, false);
});
