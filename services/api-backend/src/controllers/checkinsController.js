import { inMemoryDB } from '../models/db.js';

export async function createCheckin(req, res) {
  const userId = req.headers['x-user-id'] || 'usr_alex';
  const { mood_score, stress_score, energy_level, sleep_hours, notes } = req.body;

  const checkin = {
    id: `chk_${Date.now()}`,
    user_id: userId,
    date: new Date().toISOString().split('T')[0],
    mood_score,
    stress_score,
    energy_level,
    sleep_hours,
    notes,
    created_at: new Date().toISOString()
  };

  inMemoryDB.checkins.unshift(checkin);
  return res.status(201).json({ status: 'success', checkin });
}

export async function getCheckins(req, res) {
  const userId = req.headers['x-user-id'] || 'usr_alex';
  const userCheckins = inMemoryDB.checkins.filter(c => c.user_id === userId);
  return res.json({ status: 'success', data: userCheckins });
}
