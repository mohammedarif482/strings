class ContentEntry {
  final String id;
  final String stateTag;
  final List<String> phaseApplicability; // ["luteal", "menstrual", "follicular", "ovulatory", "any"]
  final String title;
  final String paraphrasedSummary;
  final String sourceReference;
  final String actionTipForUser;
  final String partnerNudgeTemplate;
  final int durationMinutes;
  final String contentType;

  const ContentEntry({
    required this.id,
    required this.stateTag,
    required this.phaseApplicability,
    required this.title,
    required this.paraphrasedSummary,
    required this.sourceReference,
    required this.actionTipForUser,
    required this.partnerNudgeTemplate,
    this.durationMinutes = 10,
    this.contentType = 'Guided',
  });
}
