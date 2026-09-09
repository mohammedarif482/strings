class DailyCheckin {
  final String id;
  final String userId;
  final DateTime date;
  final int moodScore;
  final int stressScore;
  final int energyLevel;
  final double sleepHours;
  final String? notes;

  DailyCheckin({
    required this.id,
    required this.userId,
    required this.date,
    required this.moodScore,
    required this.stressScore,
    required this.energyLevel,
    required this.sleepHours,
    this.notes,
  });

  factory DailyCheckin.fromJson(Map<String, dynamic> json) {
    return DailyCheckin(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      date: DateTime.parse(json['date']),
      moodScore: json['mood_score'] ?? 5,
      stressScore: json['stress_score'] ?? 5,
      energyLevel: json['energy_level'] ?? 5,
      sleepHours: (json['sleep_hours'] as num?)?.toDouble() ?? 7.5,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'date': date.toIso8601String().split('T')[0],
    'mood_score': moodScore,
    'stress_score': stressScore,
    'energy_level': energyLevel,
    'sleep_hours': sleepHours,
    'notes': notes,
  };
}
