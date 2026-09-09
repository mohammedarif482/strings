import test from 'node:test';
import assert from 'node:assert/strict';
import { db } from '../src/db/database.js';

test('Partner Flow: Generate 6-digit alphanumeric invite code and 24h expiration', () => {
  const invite = db.createPartnerInvite('alex_01');
  assert.equal(invite.code.length, 6);
  assert.equal(invite.deepLink, `app://swing/pair?code=${invite.code}`);
  assert.equal(invite.inviterId, 'alex_01');
  assert.equal(invite.status, 'active');

  const diffHours = (new Date(invite.expiresAt) - new Date(invite.createdAt)) / (1000 * 60 * 60);
  assert.ok(Math.abs(diffHours - 24) < 0.1);
});

test('Partner Flow: Prevent self-pairing', () => {
  const invite = db.createPartnerInvite('alex_01');
  const result = db.redeemPartnerInvite('alex_01', invite.code);
  assert.equal(result.success, false);
  assert.match(result.error, /Cannot pair an account with yourself/i);
});

test('Partner Flow: Successfully unpair and pair two users', () => {
  // 1. Unlink Alex and Sarah
  db.unlinkPartner('alex_01');
  assert.equal(db.getUser('alex_01').partnerId, null);
  assert.equal(db.getUser('sarah_02').partnerId, null);

  // 2. Sarah creates invite
  const invite = db.createPartnerInvite('sarah_02');
  assert.ok(invite.code);

  // 3. Alex redeems invite
  const redeemResult = db.redeemPartnerInvite('alex_01', invite.code);
  assert.equal(redeemResult.success, true);
  assert.equal(redeemResult.partner.id, 'sarah_02');

  // Verify bidirectional link
  assert.equal(db.getUser('alex_01').partnerId, 'sarah_02');
  assert.equal(db.getUser('sarah_02').partnerId, 'alex_01');
});

test('Partner Flow: Privacy bounds sanitize cycle details and raw scores by default', () => {
  // Sarah's privacy defaults
  const privacy = db.getPrivacySettings('sarah_02');
  assert.equal(privacy.sharePredictedStateAlerts, true);
  assert.equal(privacy.shareCyclePhaseDetails, false);
  assert.equal(privacy.shareDailyCheckinScores, false);

  // Update privacy toggle for cycle details
  db.updatePrivacySettings('sarah_02', { shareCyclePhaseDetails: true });
  const updated = db.getPrivacySettings('sarah_02');
  assert.equal(updated.shareCyclePhaseDetails, true);
  assert.equal(updated.shareDailyCheckinScores, false);
});

test('Partner Flow: Nudge feedback logs was_helpful flag and support reaction', () => {
  const nudge = db.saveNudge({
    senderId: 'sarah_02',
    recipientId: 'alex_01',
    message: 'High cortisol alert for tomorrow.',
    suggestedSupport: 'Prepare calming herbal tea',
  });

  const feedbackResult = db.updateNudgeFeedback(nudge.id, true, "I've got dinner covered tonight ❤️");
  assert.equal(feedbackResult.was_helpful, true);
  assert.equal(feedbackResult.isHelpful, true);
  assert.equal(feedbackResult.supportReaction, "I've got dinner covered tonight ❤️");
});
