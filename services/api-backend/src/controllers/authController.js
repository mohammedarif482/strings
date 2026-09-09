import { inMemoryDB, pool } from '../models/db.js';

export async function register(req, res) {
  const { email, cycle_start_date, average_cycle_length } = req.body;
  const user = {
    id: `usr_${Date.now()}`,
    email,
    cycle_start_date: cycle_start_date || new Date().toISOString().split('T')[0],
    average_cycle_length: average_cycle_length || 28
  };
  inMemoryDB.users.push(user);
  return res.status(201).json({ status: 'success', user });
}

export async function getProfile(req, res) {
  const userId = req.headers['x-user-id'] || 'usr_alex';
  const user = inMemoryDB.users.find(u => u.id === userId) || inMemoryDB.users[0];
  return res.json({ status: 'success', user });
}
