import { inMemoryDB } from '../models/db.js';

export async function createNudge(req, res) {
  const senderId = req.headers['x-user-id'] || 'usr_alex';
  const { recipient_id, message, prediction_id } = req.body;

  const nudge = {
    id: `ndg_${Date.now()}`,
    sender_id: senderId,
    recipient_id,
    prediction_id,
    message,
    was_helpful: null,
    created_at: new Date().toISOString()
  };

  inMemoryDB.nudges.unshift(nudge);
  return res.status(201).json({ status: 'success', nudge });
}

export async function submitFeedback(req, res) {
  const { id } = req.params;
  const { was_helpful, support_reaction } = req.body;

  const nudge = inMemoryDB.nudges.find(n => n.id === id);
  if (nudge) {
    nudge.was_helpful = was_helpful;
    nudge.support_reaction = support_reaction;
  }

  return res.json({ status: 'success', nudge });
}
