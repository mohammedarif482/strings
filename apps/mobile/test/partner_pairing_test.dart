import 'package:flutter_test/flutter_test.dart';
import 'package:aivo_mobile/models/prediction_models.dart';
import 'package:aivo_mobile/models/wellness_state.dart';

void main() {
  group('Partner Pairing & Privacy Bounds Unit Tests', () {
    test('Default privacy bounds ensure cycle details and checkin scores are private', () {
      const settings = PrivacySettings();
      expect(settings.sharePredictedStateAlerts, isTrue);
      expect(settings.shareCyclePhaseDetails, isFalse);
      expect(settings.shareDailyCheckinScores, isFalse);

      final updated = settings.copyWith(shareCyclePhaseDetails: true);
      expect(updated.shareCyclePhaseDetails, isTrue);
      expect(updated.shareDailyCheckinScores, isFalse);
    });

    test('PartnerInvite JSON serialization and deep link formatting', () {
      final json = {
        'code': 'SWG789',
        'deepLink': 'app://swing/pair?code=SWG789',
        'expiresAt': '2026-09-11T12:00:00.000Z',
        'inviterName': 'Sarah',
      };

      final invite = PartnerInvite.fromJson(json);
      expect(invite.code, 'SWG789');
      expect(invite.deepLink, 'app://swing/pair?code=SWG789');
      expect(invite.inviterName, 'Sarah');
    });

    test('PartnerNudge supports reaction feedback and helpfulness', () {
      final nudge = PartnerNudge(
        senderId: 'alex_01',
        recipientId: 'sarah_02',
        message: 'Cortisol Alert for tomorrow',
        suggestedSupport: 'Prepare dinner and lower conversational friction',
        timestamp: DateTime.now(),
      );

      expect(nudge.isHelpful, isNull);
      expect(nudge.supportReaction, isNull);

      final withReaction = nudge.copyWith(
        isHelpful: true,
        supportReaction: "I've got dinner covered tonight ❤️",
      );

      expect(withReaction.isHelpful, isTrue);
      expect(withReaction.supportReaction, "I've got dinner covered tonight ❤️");
    });

    test('WellnessState unpairing and pairing state toggle', () async {
      final state = WellnessState();
      expect(state.isPaired, isTrue);

      // Unpair partner
      state.unlinkCurrentPartner();
      expect(state.isPaired, isFalse);

      // Pair partner with valid code
      final paired = await state.redeemInviteCode('SWG789');
      expect(paired, isTrue);
      expect(state.isPaired, isTrue);
    });
  });
}
