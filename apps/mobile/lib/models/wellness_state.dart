import 'package:flutter/foundation.dart';
import 'prediction_models.dart';
import 'content_entry.dart';
import '../services/prediction_engine.dart';
import '../services/mock_data_generator.dart';
import '../services/content_matcher.dart';
import '../services/aivo_cloud_client.dart';

class WellnessState extends ChangeNotifier {
  late User _currentUser;
  late User _partnerUser;
  late List<DailyCheckin> _userCheckins;
  late List<DailyCheckin> _partnerCheckins;
  late WearableData _userWearable;
  late WearableData _partnerWearable;
  late PredictionResult _userPrediction;
  late PredictionResult _partnerPrediction;
  late ContentEntry _userProtocol;
  late ContentEntry _partnerProtocol;
  final List<PartnerNudge> _nudges = [];

  final AivoCloudClient _cloudClient = AivoCloudClient();
  bool _isCloudConnected = false;
  int _selectedDay = 12;
  bool _isPlaying = true;
  int _heartRate = 89;
  bool? _lastNudgeFeedback;
  String? _lastReactionSent;
  String? _incomingPartnerReaction;

  bool _isPaired = true;
  PartnerInvite? _currentInvite;
  PrivacySettings _privacySettings = const PrivacySettings();

  WellnessState() {
    _initializeData();
    _initCloudSync();
  }

  void _initializeData() {
    final dataset = MockDataGenerator.createSynchronizedCoupleDataset();
    _currentUser = dataset['userA'] as User;
    _partnerUser = dataset['userB'] as User;
    _userCheckins = dataset['alexCheckins'] as List<DailyCheckin>;
    _partnerCheckins = dataset['sarahCheckins'] as List<DailyCheckin>;
    _userWearable = dataset['alexWearable'] as WearableData;
    _partnerWearable = dataset['sarahWearable'] as WearableData;
    _nudges.addAll(dataset['initialNudges'] as List<PartnerNudge>);
    _isPaired = _currentUser.partnerId != null;

    _recalculatePredictions();
  }

  /// Connects to cloud backend REST and real-time push streams
  Future<void> _initCloudSync() async {
    final dashboard = await _cloudClient.fetchDashboard();
    if (dashboard != null) {
      _isCloudConnected = true;
      _applyCloudDashboard(dashboard);
      notifyListeners();
    }

    // Also fetch partner state with privacy rules
    await refreshPartnerState();

    _cloudClient.connectRealtimeStream();
    _cloudClient.realtimeEvents.listen((event) {
      _isCloudConnected = true;
      _handleRealtimeCloudEvent(event);
      notifyListeners();
    });
  }

  Future<void> refreshPartnerState() async {
    final res = await _cloudClient.fetchPartnerState();
    if (res != null) {
      _isPaired = res['isPaired'] as bool? ?? false;
      notifyListeners();
    }
  }

  void _applyCloudDashboard(Map<String, dynamic> data) {
    if (data.containsKey('vitals') && data['vitals'] != null) {
      final v = data['vitals'];
      _userWearable = WearableData(
        hrv: (v['hrv'] as num).toDouble(),
        restingHR: (v['restingHR'] as num).toInt(),
        deepSleepRatio: (v['deepSleepRatio'] as num).toDouble(),
      );
      _heartRate = _userWearable.restingHR + 31; // current reading around 89
    }
  }

  void _handleRealtimeCloudEvent(Map<String, dynamic> event) {
    final type = event['type'] as String?;
    final payload = event['payload'] as Map<String, dynamic>?;

    if (type == 'VITALS_TICK' && payload != null) {
      if (payload.containsKey('vitals')) {
        final v = payload['vitals'];
        _userWearable = WearableData(
          hrv: (v['hrv'] as num).toDouble(),
          restingHR: (v['restingHR'] as num).toInt(),
          deepSleepRatio: (v['deepSleepRatio'] as num).toDouble(),
        );
      }
    } else if (type == 'PARTNER_NUDGE_TRIGGERED' && payload != null) {
      final alert = payload['alert'] as String? ?? 'High Cortisol Alert';
      final tip = payload['actionTip'] as String? ?? 'Supportive presence';
      _nudges.add(PartnerNudge(
        senderId: 'system_aivo_engine',
        recipientId: _currentUser.id,
        message: alert,
        suggestedSupport: tip,
        timestamp: DateTime.now(),
      ));
    } else if (type == 'PARTNER_PAIRED' && payload != null) {
      _isPaired = true;
      final partnerName = payload['partnerName'] as String? ?? 'Partner';
      final partnerId = payload['partnerId'] as String? ?? 'partner_02';
      _partnerUser = User(
        id: partnerId,
        name: partnerName,
        partnerId: _currentUser.id,
        cycleStartDate: DateTime.now().subtract(const Duration(days: 23)),
      );
      _recalculatePredictions();
    } else if (type == 'PARTNER_UNLINKED') {
      _isPaired = false;
      _currentInvite = null;
    } else if (type == 'PARTNER_REACTION_RECEIVED' && payload != null) {
      _incomingPartnerReaction = payload['supportReaction'] as String?;
    }
  }

  void _recalculatePredictions() {
    final now = DateTime.now();
    final userCycleDay = _currentUser.getCurrentCycleDay(now);
    final partnerCycleDay = _partnerUser.getCurrentCycleDay(now);

    _userPrediction = PredictionEngine.calculatePredictedState(
      userId: _currentUser.id,
      date: now,
      checkins: _userCheckins,
      wearable: _userWearable,
      cycleDay: userCycleDay,
    );

    _partnerPrediction = PredictionEngine.calculatePredictedState(
      userId: _partnerUser.id,
      date: now,
      checkins: _partnerCheckins,
      wearable: _partnerWearable,
      cycleDay: partnerCycleDay,
    );

    _userProtocol = ContentMatcher.getProtocolForState(_userPrediction);
    _partnerProtocol = ContentMatcher.getProtocolForState(_partnerPrediction);
  }

  // Getters for UI binding
  User get currentUser => _currentUser;
  User get partnerUser => _partnerUser;
  PredictionResult get userPrediction => _userPrediction;
  PredictionResult get partnerPrediction => _partnerPrediction;
  ContentEntry get userProtocol => _userProtocol;
  ContentEntry get partnerProtocol => _partnerProtocol;
  WearableData get userWearable => _userWearable;
  WearableData get partnerWearable => _partnerWearable;
  List<DailyCheckin> get userCheckins => List.unmodifiable(_userCheckins);
  List<PartnerNudge> get nudges => List.unmodifiable(_nudges);
  bool? get lastNudgeFeedback => _lastNudgeFeedback;
  String? get lastReactionSent => _lastReactionSent;
  String? get incomingPartnerReaction => _incomingPartnerReaction;
  bool get isCloudConnected => _isCloudConnected;
  bool get isPaired => _isPaired;
  PartnerInvite? get currentInvite => _currentInvite;
  PrivacySettings get privacySettings => _privacySettings;

  int get selectedDay => _selectedDay;
  bool get isPlaying => _isPlaying;
  int get heartRate => _heartRate;
  bool get partnerNudgeSent => _nudges.any((n) => n.recipientId == _partnerUser.id && n.timestamp.difference(DateTime.now()).inMinutes.abs() < 60);

  String get formattedPartnerNudgeTemplate =>
      ContentMatcher.formatPartnerNudge(_partnerProtocol.partnerNudgeTemplate, _partnerUser.name);

  int get wellnessScore {
    final baseScore = 100 - (_userPrediction.combinedStressIndex * 50);
    return baseScore.clamp(45, 99).toInt();
  }

  int get energyPercentage {
    if (_userCheckins.isEmpty) return 78;
    return (_userCheckins.last.energyLevel * 10).clamp(20, 100);
  }

  String get currentMood {
    if (_userCheckins.isEmpty) return 'Calm';
    final mood = _userCheckins.last.moodScore;
    if (mood <= 3) return 'Tense';
    if (mood <= 6) return 'Balanced';
    if (mood <= 8) return 'Calm';
    return 'Vibrant';
  }

  int get stressLevel => _userCheckins.isNotEmpty ? _userCheckins.last.stressScore : 3;
  double get sleepHours => _userCheckins.isNotEmpty ? _userCheckins.last.sleepHours : 8.0;

  void setSelectedDay(int day) {
    _selectedDay = day;
    notifyListeners();
  }

  void togglePlay() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  /// Submits checkin to cloud backend and updates state
  Future<void> submitDailyCheckin({
    required int mood,
    required int stress,
    required int energy,
    required double sleep,
  }) async {
    final now = DateTime.now();
    final newCheckin = DailyCheckin(
      userId: _currentUser.id,
      date: now,
      moodScore: mood,
      stressScore: stress,
      energyLevel: energy,
      sleepHours: sleep,
    );

    _userCheckins.add(newCheckin);
    _recalculatePredictions();
    notifyListeners();

    // Asynchronously dispatch to cloud engine
    _cloudClient.submitCheckin(
      mood: mood,
      stress: stress,
      energy: energy,
      sleep: sleep,
    );
  }

  void sendPartnerNudge({String? customMessage, String? supportType}) {
    final message = customMessage ?? formattedPartnerNudgeTemplate;
    final support = supportType ?? _partnerProtocol.actionTipForUser;

    final nudge = PartnerNudge(
      senderId: _currentUser.id,
      recipientId: _partnerUser.id,
      message: message,
      suggestedSupport: support,
      timestamp: DateTime.now(),
    );

    _nudges.add(nudge);
    _lastNudgeFeedback = null;
    notifyListeners();

    // Push to cloud
    _cloudClient.sendPartnerNudge(
      recipientId: _partnerUser.id,
      message: message,
      suggestedSupport: support,
    );
  }

  void logNudgeFeedback(bool isHelpful, {String? supportReaction}) {
    _lastNudgeFeedback = isHelpful;
    if (_nudges.isNotEmpty) {
      final last = _nudges.last;
      _nudges[_nudges.length - 1] = last.copyWith(
        isHelpful: isHelpful,
        supportReaction: supportReaction,
      );

      _cloudClient.logNudgeFeedback(
        nudgeId: last.id,
        isHelpful: isHelpful,
        supportReaction: supportReaction,
      );
    }
    notifyListeners();
  }

  /// Sends a tap-back reaction back to the partner
  Future<void> sendSupportReaction(String reactionText) async {
    _lastReactionSent = reactionText;
    if (_nudges.isNotEmpty) {
      final last = _nudges.last;
      logNudgeFeedback(true, supportReaction: reactionText);
    }
    notifyListeners();
  }

  /// Generates a 6-digit partner invitation code & deep link
  Future<PartnerInvite?> generateInviteCode() async {
    final res = await _cloudClient.createPartnerInvite();
    if (res != null && res['code'] != null) {
      _currentInvite = PartnerInvite.fromJson(res);
      notifyListeners();
      return _currentInvite;
    }
    // Fallback if offline
    _currentInvite = PartnerInvite(
      code: 'SWG789',
      deepLink: 'app://swing/pair?code=SWG789',
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
      inviterName: _currentUser.name,
    );
    notifyListeners();
    return _currentInvite;
  }

  /// Redeem an invite code to pair with a partner
  Future<bool> redeemInviteCode(String code) async {
    final res = await _cloudClient.redeemPartnerInvite(code);
    if (res != null && res['success'] == true) {
      _isPaired = true;
      if (res['partner'] != null) {
        _partnerUser = User(
          id: res['partner']['id'] as String? ?? 'partner_02',
          name: res['partner']['name'] as String? ?? 'Partner',
          partnerId: _currentUser.id,
          cycleStartDate: DateTime.now().subtract(const Duration(days: 23)),
        );
      }
      _recalculatePredictions();
      notifyListeners();
      return true;
    }
    // Demo fallback for testing code "SWG789"
    if (code.trim().toUpperCase() == 'SWG789' || code.trim().toUpperCase() == 'AIVO89') {
      _isPaired = true;
      _partnerUser = User(
        id: 'sarah_02',
        name: 'Sarah',
        partnerId: _currentUser.id,
        cycleStartDate: DateTime.now().subtract(const Duration(days: 23)),
      );
      _recalculatePredictions();
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Unlinks current partner
  Future<void> unlinkCurrentPartner() async {
    _isPaired = false;
    _currentInvite = null;
    notifyListeners();
    await _cloudClient.unlinkPartner();
  }

  /// Updates granular privacy controls
  Future<void> updatePrivacyToggles({
    bool? sharePredictedStateAlerts,
    bool? shareCyclePhaseDetails,
    bool? shareDailyCheckinScores,
  }) async {
    _privacySettings = _privacySettings.copyWith(
      sharePredictedStateAlerts: sharePredictedStateAlerts,
      shareCyclePhaseDetails: shareCyclePhaseDetails,
      shareDailyCheckinScores: shareDailyCheckinScores,
    );
    notifyListeners();

    await _cloudClient.updatePrivacySettings(_privacySettings.toJson());
  }

  @override
  void dispose() {
    _cloudClient.dispose();
    super.dispose();
  }
}
