import 'dart:math';
import '../models/prediction_models.dart';

class MockDataGenerator {
  /// Generates a realistic simulated history of check-ins and wearables for a user.
  /// Simulates 28-day biological curves:
  /// - HRV drops in late luteal (days 21-28)
  /// - Resting HR climbs by 3-5 bpm before period
  /// - Sleep efficiency varies based on progesterone curve
  static List<DailyCheckin> generateSimulatedUserHistory({
    required String userId,
    required DateTime cycleStartDate,
    int days = 28,
  }) {
    final List<DailyCheckin> checkins = [];
    final now = DateTime.now();

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final cycleDay = ((date.difference(cycleStartDate).inDays) % 28) + 1;

      // Realistic biological curve simulation
      int mood;
      int stress;
      int energy;
      double sleep;

      if (cycleDay >= 1 && cycleDay <= 5) {
        // Menstrual: Low energy, moderate fatigue, restful sleep
        mood = 5 + (i % 2);
        stress = 4 + (i % 2);
        energy = 4 + (i % 3);
        sleep = 7.5 + ((i % 2) * 0.5);
      } else if (cycleDay >= 6 && cycleDay <= 13) {
        // Follicular: High estrogen, high energy, low stress, high mood
        mood = 8 + (i % 3 == 0 ? 1 : 0);
        stress = 2 + (i % 2);
        energy = 8 + (i % 2);
        sleep = 8.0 + ((i % 2) * 0.2);
      } else if (cycleDay == 14) {
        // Ovulatory: Peak vitality
        mood = 9;
        stress = 2;
        energy = 9;
        sleep = 7.8;
      } else if (cycleDay >= 15 && cycleDay <= 20) {
        // Early Luteal: Steady progesterone
        mood = 7;
        stress = 4;
        energy = 7;
        sleep = 7.4;
      } else {
        // Late Luteal (Days 21-28): Cortisol sensitivity, PMS tension, lower sleep
        mood = 4 + (i % 2);
        stress = 7 + (i % 3); // elevated stress (7-9)
        energy = 5 - (i % 2);
        sleep = 6.2 + ((i % 3) * 0.3); // sleep deficit < 7 hrs!
      }

      checkins.add(DailyCheckin(
        userId: userId,
        date: date,
        moodScore: mood.clamp(1, 10),
        stressScore: stress.clamp(1, 10),
        energyLevel: energy.clamp(1, 10),
        sleepHours: double.parse(sleep.toStringAsFixed(1)),
      ));
    }

    return checkins;
  }

  /// Generates synthetic wearable telemetry based on cycle day
  static WearableData generateWearableData(int cycleDay) {
    if (cycleDay >= 21 && cycleDay <= 28) {
      // Late luteal: HRV drops, resting HR elevated
      return WearableData(
        hrv: 48.0,
        restingHR: 76,
        deepSleepRatio: 0.14,
      );
    } else if (cycleDay >= 6 && cycleDay <= 14) {
      // Follicular / Ovulatory: High HRV, lower resting HR
      return WearableData(
        hrv: 78.0,
        restingHR: 58,
        deepSleepRatio: 0.24,
      );
    } else {
      return WearableData(
        hrv: 62.0,
        restingHR: 66,
        deepSleepRatio: 0.18,
      );
    }
  }

  /// Creates a synchronized couple pairing (User A: Alex, User B: Sarah)
  static Map<String, dynamic> createSynchronizedCoupleDataset() {
    final now = DateTime.now();

    // User A: Alex Rivera (Day 12 of cycle / cycle tracking partner)
    final alexStartDate = now.subtract(const Duration(days: 11));
    final userA = User(
      id: 'alex_01',
      name: 'Dr. Alex Rivera',
      partnerId: 'sarah_02',
      cycleStartDate: alexStartDate,
      averageCycleLength: 28,
    );

    // User B: Sarah (Day 24 of cycle, late luteal cortisol vulnerability)
    final sarahStartDate = now.subtract(const Duration(days: 23));
    final userB = User(
      id: 'sarah_02',
      name: 'Sarah',
      partnerId: 'alex_01',
      cycleStartDate: sarahStartDate,
      averageCycleLength: 28,
    );

    final alexCheckins = generateSimulatedUserHistory(
      userId: userA.id,
      cycleStartDate: alexStartDate,
      days: 14,
    );

    final sarahCheckins = generateSimulatedUserHistory(
      userId: userB.id,
      cycleStartDate: sarahStartDate,
      days: 28,
    );

    final alexWearable = generateWearableData(12);
    final sarahWearable = generateWearableData(24);

    final initialNudges = [
      PartnerNudge(
        senderId: 'alex_01',
        recipientId: 'sarah_02',
        message: 'Sent supportive lavender tea & cleared tonight\'s dinner duties.',
        suggestedSupport: 'Early bedtime & magnesium soak',
        timestamp: now.subtract(const Duration(hours: 18)),
        isHelpful: true,
      ),
    ];

    return {
      'userA': userA,
      'userB': userB,
      'alexCheckins': alexCheckins,
      'sarahCheckins': sarahCheckins,
      'alexWearable': alexWearable,
      'sarahWearable': sarahWearable,
      'initialNudges': initialNudges,
    };
  }
}
