import 'package:flutter_test/flutter_test.dart';
import 'package:aivo_mobile/models/prediction_models.dart';
import 'package:aivo_mobile/services/content_matcher.dart';
import 'package:aivo_mobile/data/content_seed_data.dart';

void main() {
  group('Content Matcher & Seed Library Tests', () {
    test('Seed library contains at least 18 evidence-based protocols', () {
      expect(contentSeedLibrary.length, greaterThanOrEqualTo(18));
      final hasLuteal = contentSeedLibrary.any((e) => e.stateTag == 'luteal_high_cortisol');
      final hasMenstrual = contentSeedLibrary.any((e) => e.stateTag == 'menstrual_low_energy_recovery');
      final hasFollicular = contentSeedLibrary.any((e) => e.stateTag == 'follicular_rising_momentum');
      final hasOvulatory = contentSeedLibrary.any((e) => e.stateTag == 'ovulatory_peak_social_energy');

      expect(hasLuteal, isTrue);
      expect(hasMenstrual, isTrue);
      expect(hasFollicular, isTrue);
      expect(hasOvulatory, isTrue);
    });

    test('Matches Late Luteal High Cortisol Protocol with Action Tip and Partner Template', () {
      final prediction = PredictionResult(
        userId: 'sarah_02',
        date: DateTime.now(),
        predictedState: 'High Stress / High Cortisol State',
        confidenceScore: 0.92,
        primaryDriver: 'Late Luteal Cortisol Spike (Day 24)',
        suggestedActionTag: 'Cortisol Reset & Somatic Breathing',
        cyclePhase: CyclePhase.luteal,
        cycleDay: 24,
        combinedStressIndex: 0.72,
        rollingStressAvg: 8.0,
        rollingMoodAvg: 4.0,
        rollingSleepAvg: 6.2,
      );

      final protocol = ContentMatcher.getProtocolForState(prediction);

      expect(protocol.stateTag, equals('late_luteal_sleep_deficit'));
      expect(protocol.title, equals('Restore Cortisol Balance'));
      expect(protocol.actionTipForUser, contains('Non-Sleep Deep Rest'));

      final formattedNudge = ContentMatcher.formatPartnerNudge(protocol.partnerNudgeTemplate, 'Sarah');
      expect(formattedNudge, contains('Sarah'));
      expect(formattedNudge, contains('sleep debt'));
    });

    test('Matches Follicular Rising Momentum when stress is low and mood is high', () {
      final prediction = PredictionResult(
        userId: 'alex_01',
        date: DateTime.now(),
        predictedState: 'Balanced / Peak Recovery State',
        confidenceScore: 0.95,
        primaryDriver: 'High Parasympathetic Tone',
        suggestedActionTag: 'Mindful Focus & Vitality Check-in',
        cyclePhase: CyclePhase.follicular,
        cycleDay: 9,
        combinedStressIndex: 0.12,
        rollingStressAvg: 2.0,
        rollingMoodAvg: 8.5,
        rollingSleepAvg: 8.0,
      );

      final protocol = ContentMatcher.getProtocolForState(prediction);

      expect(protocol.stateTag, equals('follicular_rising_momentum'));
      expect(protocol.title, equals('Cognitive Activation & Clarity'));
      expect(protocol.sourceReference, contains('Estradiol'));
    });

    test('Falls back gracefully to default_generic_recovery for unknown combinations', () {
      final prediction = PredictionResult(
        userId: 'test_user',
        date: DateTime.now(),
        predictedState: 'Unknown',
        confidenceScore: 0.50,
        primaryDriver: 'None',
        suggestedActionTag: 'None',
        cyclePhase: CyclePhase.follicular,
        cycleDay: 10,
        combinedStressIndex: 0.45,
        rollingStressAvg: 4.0,
        rollingMoodAvg: 6.0,
        rollingSleepAvg: 7.2,
      );

      final protocol = ContentMatcher.getProtocolForState(prediction);
      expect(protocol.id, isNotEmpty);
      expect(protocol.title, isNotEmpty);
      expect(protocol.actionTipForUser, isNotEmpty);
    });
  });
}
