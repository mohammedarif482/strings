import 'dart:async';
import 'dart:convert';
import 'dart:io';

class AivoCloudClient {
  static const String baseUrl = 'https://strings-api.onrender.com';
  final String url;
  final String userId;
  StreamSubscription? _sseSubscription;
  final _eventController = StreamController<Map<String, dynamic>>.broadcast();

  String get baseUrl => url;

  AivoCloudClient({
    String? baseUrl,
    this.userId = 'alex_01',
  }) : url = baseUrl ?? AivoCloudClient.baseUrl;

  Stream<Map<String, dynamic>> get realtimeEvents => _eventController.stream;

  /// Fetch initial pre-calculated dashboard state from cloud backend
  Future<Map<String, dynamic>?> fetchDashboard() async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('$baseUrl/api/v1/users/$userId/dashboard'));
      final response = await request.close().timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        return jsonDecode(body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      // Offline fallback
      return null;
    }
  }

  /// Submit 30-sec Daily Check-In to cloud prediction engine
  Future<Map<String, dynamic>?> submitCheckin({
    required int mood,
    required int stress,
    required int energy,
    required double sleep,
  }) async {
    try {
      final client = HttpClient();
      final request = await client.postUrl(Uri.parse('$baseUrl/api/v1/checkin'));
      request.headers.contentType = ContentType.json;

      final payload = jsonEncode({
        'userId': userId,
        'moodScore': mood,
        'stressScore': stress,
        'energyLevel': energy,
        'sleepHours': sleep,
      });

      request.write(payload);
      final response = await request.close().timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        return jsonDecode(body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Dispatch Partner Nudge via Cloud
  Future<bool> sendPartnerNudge({
    required String recipientId,
    required String message,
    required String suggestedSupport,
  }) async {
    try {
      final client = HttpClient();
      final request = await client.postUrl(Uri.parse('$baseUrl/api/v1/nudges'));
      request.headers.contentType = ContentType.json;

      final payload = jsonEncode({
        'senderId': userId,
        'recipientId': recipientId,
        'message': message,
        'suggestedSupport': suggestedSupport,
      });

      request.write(payload);
      final response = await request.close().timeout(const Duration(seconds: 4));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Send Nudge Helpfulness Feedback & Support Reaction to Cloud
  Future<bool> logNudgeFeedback({
    required String nudgeId,
    required bool isHelpful,
    String? supportReaction,
  }) async {
    try {
      final client = HttpClient();
      final request = await client.postUrl(Uri.parse('$baseUrl/api/v1/nudges/$nudgeId/feedback'));
      request.headers.contentType = ContentType.json;

      final payload = jsonEncode({
        'isHelpful': isHelpful,
        if (supportReaction != null) 'supportReaction': supportReaction,
      });
      request.write(payload);
      final response = await request.close().timeout(const Duration(seconds: 4));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Create 6-digit partner invite code & deep link
  Future<Map<String, dynamic>?> createPartnerInvite() async {
    try {
      final client = HttpClient();
      final request = await client.postUrl(Uri.parse('$baseUrl/api/v1/partners/invite/create'));
      request.headers.contentType = ContentType.json;

      final payload = jsonEncode({ 'userId': userId });
      request.write(payload);
      final response = await request.close().timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        return jsonDecode(body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Redeem 6-digit partner invite code
  Future<Map<String, dynamic>?> redeemPartnerInvite(String code) async {
    try {
      final client = HttpClient();
      final request = await client.postUrl(Uri.parse('$baseUrl/api/v1/partners/invite/redeem'));
      request.headers.contentType = ContentType.json;

      final payload = jsonEncode({
        'userId': userId,
        'code': code.trim().toUpperCase(),
      });
      request.write(payload);
      final response = await request.close().timeout(const Duration(seconds: 4));

      final body = await response.transform(utf8.decoder).join();
      final data = jsonDecode(body) as Map<String, dynamic>;
      return {
        'statusCode': response.statusCode,
        ...data,
      };
    } catch (e) {
      return { 'success': false, 'error': 'Connection failed' };
    }
  }

  /// Fetch partner state with privacy boundaries enforced
  Future<Map<String, dynamic>?> fetchPartnerState() async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('$baseUrl/api/v1/partners/state?userId=$userId'));
      final response = await request.close().timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        return jsonDecode(body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Update user privacy toggles
  Future<bool> updatePrivacySettings(Map<String, dynamic> settings) async {
    try {
      final client = HttpClient();
      final request = await client.putUrl(Uri.parse('$baseUrl/api/v1/users/$userId/privacy'));
      request.headers.contentType = ContentType.json;

      request.write(jsonEncode(settings));
      final response = await request.close().timeout(const Duration(seconds: 4));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Unlink current partner
  Future<bool> unlinkPartner() async {
    try {
      final client = HttpClient();
      final request = await client.postUrl(Uri.parse('$baseUrl/api/v1/partners/unlink'));
      request.headers.contentType = ContentType.json;

      request.write(jsonEncode({ 'userId': userId }));
      final response = await request.close().timeout(const Duration(seconds: 4));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Connect to real-time Server-Sent Events stream for live updates
  void connectRealtimeStream() {
    _sseSubscription?.cancel();
    try {
      final client = HttpClient();
      client.getUrl(Uri.parse('$baseUrl/api/v1/stream?userId=$userId'))
          .then((request) => request.close())
          .then((response) {
            _sseSubscription = response
                .transform(utf8.decoder)
                .transform(const LineSplitter())
                .listen((line) {
                  if (line.startsWith('data: ')) {
                    final dataStr = line.substring(6).trim();
                    try {
                      final json = jsonDecode(dataStr) as Map<String, dynamic>;
                      _eventController.add(json);
                    } catch (_) {}
                  }
                }, onError: (_) {
                  // Auto-reconnect in 5s
                  Future.delayed(const Duration(seconds: 5), connectRealtimeStream);
                });
          }).catchError((_) {
            Future.delayed(const Duration(seconds: 5), connectRealtimeStream);
          });
    } catch (_) {}
  }

  void dispose() {
    _sseSubscription?.cancel();
    _eventController.close();
  }
}
