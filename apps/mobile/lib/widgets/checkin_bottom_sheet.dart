import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/aivo_theme.dart';
import '../models/wellness_state.dart';

class CheckInBottomSheet extends StatefulWidget {
  final WellnessState state;
  const CheckInBottomSheet({super.key, required this.state});

  static void show(BuildContext context, WellnessState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CheckInBottomSheet(state: state),
    );
  }

  @override
  State<CheckInBottomSheet> createState() => _CheckInBottomSheetState();
}

class _CheckInBottomSheetState extends State<CheckInBottomSheet> {
  late double _mood;
  late double _stress;
  late double _energy;
  late double _sleep;

  @override
  void initState() {
    super.initState();
    _mood = 8;
    _stress = widget.state.stressLevel.toDouble();
    _energy = widget.state.energyPercentage.toDouble();
    _sleep = widget.state.sleepHours;
  }

  String _getMoodLabel(double val) {
    if (val <= 3) return 'Vulnerable';
    if (val <= 6) return 'Balanced';
    if (val <= 8) return 'Calm & Centered';
    return 'Vibrant & Radiating';
  }

  String _getStressLabel(double val) {
    if (val <= 3) return 'Low Cortisol (Optimal)';
    if (val <= 6) return 'Moderate Tension';
    if (val <= 8) return 'Elevated Stress';
    return 'Cortisol Spike Warning';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
        left: 20,
        right: 20,
        top: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF141219).withOpacity(0.96),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.75),
            blurRadius: 40,
            offset: const Offset(0, -10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grab handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AivoColors.orange.withOpacity(0.2),
                            ),
                            child: const Icon(
                              Icons.auto_awesome,
                              color: AivoColors.orangeLight,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '30-Sec Quick Check-In',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Calibrating biological & cortisol forecast',
                        style: TextStyle(
                          color: AivoColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AivoColors.textSecondary, size: 20),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const SizedBox(height: 18),

              // Slider 1: Mood
              _buildSliderCard(
                icon: Icons.sentiment_satisfied_alt_rounded,
                title: 'Current Mood',
                valueText: '${_getMoodLabel(_mood)} (${_mood.toInt()}/10)',
                slider: Slider(
                  value: _mood,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  activeColor: AivoColors.orange,
                  inactiveColor: Colors.white.withOpacity(0.1),
                  onChanged: (v) => setState(() => _mood = v),
                ),
              ),
              const SizedBox(height: 10),

              // Slider 2: Stress / Cortisol
              _buildSliderCard(
                icon: Icons.favorite_border_rounded,
                title: 'Stress & Tension',
                valueText: '${_getStressLabel(_stress)} (${_stress.toInt()}/10)',
                slider: Slider(
                  value: _stress,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  activeColor: AivoColors.orangeBright,
                  inactiveColor: Colors.white.withOpacity(0.1),
                  onChanged: (v) => setState(() => _stress = v),
                ),
              ),
              const SizedBox(height: 10),

              // Slider 3: Energy
              _buildSliderCard(
                icon: Icons.bolt_rounded,
                title: 'Physical Energy',
                valueText: '${_energy.toInt()}%',
                slider: Slider(
                  value: _energy,
                  min: 20,
                  max: 100,
                  activeColor: AivoColors.orange,
                  inactiveColor: Colors.white.withOpacity(0.1),
                  onChanged: (v) => setState(() => _energy = v),
                ),
              ),
              const SizedBox(height: 10),

              // Slider 4: Sleep Quality
              _buildSliderCard(
                icon: Icons.nightlight_round,
                title: 'Sleep Restfulness',
                valueText: '${_sleep.toStringAsFixed(1)} hrs',
                slider: Slider(
                  value: _sleep,
                  min: 4,
                  max: 12,
                  divisions: 16,
                  activeColor: AivoColors.orangeLight,
                  inactiveColor: Colors.white.withOpacity(0.1),
                  onChanged: (v) => setState(() => _sleep = v),
                ),
              ),
              const SizedBox(height: 20),

              // Save CTA Button
              GestureDetector(
                onTap: () {
                  widget.state.submitDailyCheckin(
                    mood: _mood.toInt(),
                    stress: _stress.toInt(),
                    energy: _energy.toInt(),
                    sleep: _sleep,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF1E1B25),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: AivoColors.orange.withOpacity(0.4)),
                      ),
                      content: Row(
                        children: const [
                          Icon(Icons.check_circle_rounded, color: Color(0xFF34D399), size: 18),
                          SizedBox(width: 8),
                          Text('Forecast & Wellness Score Updated!'),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [
                        AivoColors.orange,
                        AivoColors.orangeLight,
                        Color(0xFFFF5E1E),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AivoColors.orange.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Save & Generate Forecast',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliderCard({
    required IconData icon,
    required String title,
    required String valueText,
    required Widget slider,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: AivoColors.orangeLight, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                valueText,
                style: const TextStyle(
                  color: AivoColors.orangeBright,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          slider,
        ],
      ),
    );
  }
}
