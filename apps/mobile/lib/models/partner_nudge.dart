class PartnerNudge {
  final String id;
  final String senderId;
  final String recipientId;
  final String message;
  final bool? wasHelpful;
  final String? supportReaction;
  final DateTime createdAt;

  PartnerNudge({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.message,
    this.wasHelpful,
    this.supportReaction,
    required this.createdAt,
  });

  factory PartnerNudge.fromJson(Map<String, dynamic> json) {
    return PartnerNudge(
      id: json['id'] ?? '',
      senderId: json['sender_id'] ?? '',
      recipientId: json['recipient_id'] ?? '',
      message: json['message'] ?? '',
      wasHelpful: json['was_helpful'],
      supportReaction: json['support_reaction'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
