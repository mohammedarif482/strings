import 'package:flutter/material.dart';
import '../theme/aivo_theme.dart';
import '../models/wellness_state.dart';

class PrivacySettingsSheet extends StatefulWidget {
  final WellnessState state;

  const PrivacySettingsSheet({
    super.key,
    required this.state,
  });

  @override
  State<PrivacySettingsSheet> createState() => _PrivacySettingsSheetState();
}

class _PrivacySettingsSheetState extends State<PrivacySettingsSheet> {
  late bool _sharePredictedStateAlerts;
  late bool _shareCyclePhaseDetails;
  late bool _shareDailyCheckinScores;

  @override
  void initState() {
    super.initState();
    final p = widget.state.privacySettings;
    _sharePredictedStateAlerts = p.sharePredictedStateAlerts;
    _shareCyclePhaseDetails = p.shareCyclePhaseDetails;
    _shareDailyCheckinScores = p.shareDailyCheckinScores;
  }

  void _saveChanges() {
    widget.state.updatePrivacyToggles(
      sharePredictedStateAlerts: _sharePredictedStateAlerts,
      shareCyclePhaseDetails: _shareCyclePhaseDetails,
      shareDailyCheckinScores: _shareDailyCheckinScores,
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E1B25),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF10B981)),
        ),
        content: const Text('Privacy settings updated safely!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF131118),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.only(top: 14, left: 20, right: 20, bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title & Description
          const Text(
            'Partner Privacy Bounds',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Control what biological insights are shared with your partner. Raw biometrics and intimate scores stay private by default.',
            style: TextStyle(
              color: AivoColors.textSecondary,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 20),

          // Toggle 1: Predicted State Alerts
          _buildPrivacyToggle(
            title: 'Share Predicted State Alerts',
            subtitle: 'Allows partner to receive high-stress windows & gentle action tips',
            value: _sharePredictedStateAlerts,
            onChanged: (val) => setState(() => _sharePredictedStateAlerts = val),
            isRecommended: true,
          ),
          const SizedBox(height: 12),

          // Toggle 2: Cycle Phase Details (Default: OFF)
          _buildPrivacyToggle(
            title: 'Share Cycle Phase Details',
            subtitle: 'Displays current cycle day (e.g., Day 24) and phase name',
            value: _shareCyclePhaseDetails,
            onChanged: (val) => setState(() => _shareCyclePhaseDetails = val),
            badge: 'Default: OFF',
          ),
          const SizedBox(height: 12),

          // Toggle 3: Daily Check-in Scores (Default: OFF)
          _buildPrivacyToggle(
            title: 'Share Daily Check-in Scores',
            subtitle: 'Reveals exact numerical ratings for mood, stress, and sleep',
            value: _shareDailyCheckinScores,
            onChanged: (val) => setState(() => _shareDailyCheckinScores = val),
            badge: 'Default: OFF',
          ),
          const SizedBox(height: 24),

          // Save Button
          GestureDetector(
            onTap: _saveChanges,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: const LinearGradient(
                  colors: [AivoColors.orange, Color(0xFFFF5E1E)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AivoColors.orange.withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Text(
                'Save Privacy Preferences',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isRecommended = false,
    String? badge,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: value ? AivoColors.orange.withOpacity(0.3) : Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isRecommended) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Recommended',
                          style: TextStyle(color: Color(0xFF34D399), fontSize: 9, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                    if (badge != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(color: AivoColors.textSecondary, fontSize: 9, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AivoColors.textSecondary,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: value,
            activeColor: AivoColors.orangeBright,
            activeTrackColor: AivoColors.orange.withOpacity(0.4),
            inactiveThumbColor: Colors.white38,
            inactiveTrackColor: Colors.white10,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
