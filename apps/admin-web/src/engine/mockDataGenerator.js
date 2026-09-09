/**
 * Generates synthetic 28-day biological curves and couple pairing data
 */
export function generateSimulatedUserHistory({
  userId,
  cycleStartDate = new Date(Date.now() - 11 * 86400000),
  days = 28,
}) {
  const checkins = [];
  const now = new Date();

  for (let i = days - 1; i >= 0; i--) {
    const date = new Date(now.getTime() - i * 86400000);
    const cycleDay = (Math.floor((date - cycleStartDate) / 86400000) % 28) + 1;

    let mood, stress, energy, sleep;

    if (cycleDay >= 1 && cycleDay <= 5) {
      mood = 5 + (i % 2);
      stress = 4 + (i % 2);
      energy = 4 + (i % 3);
      sleep = 7.5 + (i % 2) * 0.5;
    } else if (cycleDay >= 6 && cycleDay <= 13) {
      mood = 8 + (i % 3 === 0 ? 1 : 0);
      stress = 2 + (i % 2);
      energy = 8 + (i % 2);
      sleep = 8.0 + (i % 2) * 0.2;
    } else if (cycleDay === 14) {
      mood = 9;
      stress = 2;
      energy = 9;
      sleep = 7.8;
    } else if (cycleDay >= 15 && cycleDay <= 20) {
      mood = 7;
      stress = 4;
      energy = 7;
      sleep = 7.4;
    } else {
      // Late Luteal (21-28)
      mood = 4 + (i % 2);
      stress = 7 + (i % 3);
      energy = 5 - (i % 2);
      sleep = 6.2 + (i % 3) * 0.3; // sleep deficit
    }

    checkins.push({
      userId,
      date,
      moodScore: Math.min(10, Math.max(1, mood)),
      stressScore: Math.min(10, Math.max(1, stress)),
      energyLevel: Math.min(10, Math.max(1, energy)),
      sleepHours: parseFloat(sleep.toFixed(1)),
    });
  }

  return checkins;
}

export function createSynchronizedCoupleDataset() {
  const now = new Date();

  // User A: Alex Rivera (Day 12, Follicular)
  const alexStartDate = new Date(now.getTime() - 11 * 86400000);
  const userA = {
    id: 'alex_01',
    name: 'Dr. Alex Rivera',
    partnerId: 'sarah_02',
    cycleStartDate: alexStartDate,
    averageCycleLength: 28,
  };

  // User B: Sarah (Day 24, Late Luteal)
  const sarahStartDate = new Date(now.getTime() - 23 * 86400000);
  const userB = {
    id: 'sarah_02',
    name: 'Sarah',
    partnerId: 'alex_01',
    cycleStartDate: sarahStartDate,
    averageCycleLength: 28,
  };

  const alexCheckins = generateSimulatedUserHistory({
    userId: userA.id,
    cycleStartDate: alexStartDate,
    days: 14,
  });

  const sarahCheckins = generateSimulatedUserHistory({
    userId: userB.id,
    cycleStartDate: sarahStartDate,
    days: 28,
  });

  const alexWearable = { hrv: 78, restingHR: 58, deepSleepRatio: 0.24 };
  const sarahWearable = { hrv: 48, restingHR: 76, deepSleepRatio: 0.14 };

  const initialNudges = [
    {
      senderId: 'alex_01',
      recipientId: 'sarah_02',
      message: 'Sent supportive lavender tea & cleared tonight’s dinner duties.',
      suggestedSupport: 'Early bedtime & magnesium soak',
      timestamp: new Date(now.getTime() - 18 * 3600000),
      isHelpful: true,
    },
  ];

  return {
    userA,
    userB,
    alexCheckins,
    sarahCheckins,
    alexWearable,
    sarahWearable,
    initialNudges,
  };
}
