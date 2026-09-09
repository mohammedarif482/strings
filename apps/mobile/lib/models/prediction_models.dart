enum CyclePhase {
  menstrual,  // Days 1-5
  follicular, // Days 6-13
  ovulatory,  // Day 14
  luteal,     // Days 15-28 (late luteal: 21-28)
}

class User {
  final String id;
  final String name;
  final String? partnerId;
  final DateTime cycleStartDate;
  final int averageCycleLength;

  User({
    required this.id,
    required this.name,
    this.partnerId,
    required this.cycleStartDate,
    this.averageCycleLength = 28,
  });

  int getCurrentCycleDay(DateTime date) {
    final diff = date.difference(cycleStartDate).inDays;
    return (diff % averageCycleLength) + 1;
  }
}

class DailyCheckin {
  final String userId;
  final DateTime date;
  final int moodScore;   // 1 - 10
  final int stressScore; // 1 - 10
  final int energyLevel; // 1 - 10
  final double sleepHours;

  DailyCheckin({
    required this.userId,
    required this.date,
    required this.moodScore,
    required this.stressScore,
    required this.energyLevel,
    required this.sleepHours,
  });
}

class WearableData {
  final double hrv;            // ms (e.g. 45 - 85)
  final int restingHR;         // bpm (e.g. 54 - 76)
  final double deepSleepRatio; // 0.0 - 1.0 (e.g. 0.22)

  WearableData({
    required this.hrv,
    required this.restingHR,
    required this.deepSleepRatio,
  });
}

class PredictionResult {
  final String userId;
  final DateTime date;
  final String predictedState;
  final double confidenceScore;
  final String primaryDriver;
  final String suggestedActionTag;
  final CyclePhase cyclePhase;
  final int cycleDay;
  final double combinedStressIndex;
  final double rollingStressAvg;
  final double rollingMoodAvg;
  final double rollingSleepAvg;

  PredictionResult({
    required this.userId,
    required this.date,
    required this.predictedState,
    required this.confidenceScore,
    required this.primaryDriver,
    required this.suggestedActionTag,
    required this.cyclePhase,
    required this.cycleDay,
    required this.combinedStressIndex,
    required this.rollingStressAvg,
    required this.rollingMoodAvg,
    required this.rollingSleepAvg,
  });

  String get phaseDisplayName {
    switch (cyclePhase) {
      case CyclePhase.menstrual:
        return 'Menstrual Phase';
      case CyclePhase.follicular:
        return 'Follicular Phase';
      case CyclePhase.ovulatory:
        return 'Ovulatory Phase';
      case CyclePhase.luteal:
        return cycleDay >= 21 ? 'Late Luteal Phase' : 'Early Luteal Phase';
    }
  }
}

class PrivacySettings {
  final bool sharePredictedStateAlerts;
  final bool shareCyclePhaseDetails;
  final bool shareDailyCheckinScores;

  const PrivacySettings({
    this.sharePredictedStateAlerts = true,
    this.shareCyclePhaseDetails = false,
    this.shareDailyCheckinScores = false,
  });

  PrivacySettings copyWith({
    bool? sharePredictedStateAlerts,
    bool? shareCyclePhaseDetails,
    bool? shareDailyCheckinScores,
  }) {
    return PrivacySettings(
      sharePredictedStateAlerts: sharePredictedStateAlerts ?? this.sharePredictedStateAlerts,
      shareCyclePhaseDetails: shareCyclePhaseDetails ?? this.shareCyclePhaseDetails,
      shareDailyCheckinScores: shareDailyCheckinScores ?? this.shareDailyCheckinScores,
    );
  }

  Map<String, dynamic> toJson() => {
    'sharePredictedStateAlerts': sharePredictedStateAlerts,
    'shareCyclePhaseDetails': shareCyclePhaseDetails,
    'shareDailyCheckinScores': shareDailyCheckinScores,
  };

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      sharePredictedStateAlerts: json['sharePredictedStateAlerts'] as bool? ?? true,
      shareCyclePhaseDetails: json['shareCyclePhaseDetails'] as bool? ?? false,
      shareDailyCheckinScores: json['shareDailyCheckinScores'] as bool? ?? false,
    );
  }
}

class PartnerInvite {
  final String code;
  final String deepLink;
  final DateTime expiresAt;
  final String inviterName;

  const PartnerInvite({
    required this.code,
    required this.deepLink,
    required this.expiresAt,
    required this.inviterName,
  });

  factory PartnerInvite.fromJson(Map<String, dynamic> json) {
    return PartnerInvite(
      code: json['code'] as String? ?? '',
      deepLink: json['deepLink'] as String? ?? '',
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : DateTime.now().add(const Duration(hours: 24)),
      inviterName: json['inviterName'] as String? ?? 'Your Partner',
    );
  }
}

class PartnerNudge {
  final String id;
  final String senderId;
  final String recipientId;
  final String message;
  final String suggestedSupport;
  final DateTime timestamp;
  final bool? isHelpful;
  final String? supportReaction;

  PartnerNudge({
    String? id,
    required this.senderId,
    required this.recipientId,
    required this.message,
    required this.suggestedSupport,
    required this.timestamp,
    this.isHelpful,
    this.supportReaction,
  }) : id = id ?? 'nudge_${DateTime.now().millisecondsSinceEpoch}';

  PartnerNudge copyWith({
    bool? isHelpful,
    String? supportReaction,
  }) {
    return PartnerNudge(
      id: id,
      senderId: senderId,
      recipientId: recipientId,
      message: message,
      suggestedSupport: suggestedSupport,
      timestamp: timestamp,
      isHelpful: isHelpful ?? this.isHelpful,
      supportReaction: supportReaction ?? this.supportReaction,
    );
  }
}
