import { inMemoryDB } from '../models/db.js';
import { calculatePrediction } from '../engine/predictionEngine.js';

export async function getTodayPrediction(req, res) {
  const userId = req.headers['x-user-id'] || 'usr_alex';
  const user = inMemoryDB.users.find(u => u.id === userId) || inMemoryDB.users[0];
  
  // Calculate cycle day
  const diffDays = Math.floor((new Date() - new Date(user.cycle_start_date)) / 86400000);
  const cycleDay = (diffDays % (user.average_cycle_length || 28)) + 1;

  const userCheckins = inMemoryDB.checkins.filter(c => c.user_id === userId).slice(0, 3);
  const latestWearable = inMemoryDB.wearables.find(w => w.user_id === userId);

  const prediction = calculatePrediction({
    cycleDay,
    recentCheckins: userCheckins,
    wearableData: latestWearable
  });

  return res.json({
    status: 'success',
    user_id: userId,
    target_date: new Date().toISOString().split('T')[0],
    cycle_day: cycleDay,
    prediction
  });
}
