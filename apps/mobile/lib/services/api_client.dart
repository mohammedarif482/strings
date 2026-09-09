import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prediction.dart';
import '../models/daily_checkin.dart';

class ApiClient {
  static const String baseUrl = 'https://strings-api.onrender.com';
  final String url;
  final String userId;

  String get baseUrl => url;

  ApiClient({
    String? baseUrl,
    this.userId = 'usr_alex',
  }) : url = baseUrl ?? ApiClient.baseUrl;

  Future<Prediction?> fetchTodayPrediction() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/v1/predictions/today'),
        headers: {'x-user-id': userId},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return Prediction.fromJson(data['prediction']);
      }
    } catch (e) {
      // Fallback
    }
    return null;
  }

  Future<bool> submitCheckin(DailyCheckin checkin) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/v1/checkins'),
        headers: {
          'Content-Type': 'application/json',
          'x-user-id': userId,
        },
        body: jsonEncode(checkin.toJson()),
      );
      return res.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
