import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/aivo_theme.dart';
import '../models/wellness_state.dart';

class DashboardScreen extends StatelessWidget {
  final WellnessState state;
  final VoidCallback onPlaySession;

  const DashboardScreen({
    super.key,
    required this.state,
    required this.onPlaySession,
  });

  @override
  Widget build(BuildContext context) {
    final days = [
      {'day': 9, 'label': 'Sat'},
      {'day': 10, 'label': 'Sun'},
      {'day': 11, 'label': 'Mon'},
      {'day': 12, 'label': 'Tue'},
      {'day': 13, 'label': 'Wed'},
      {'day': 14, 'label': 'Thu'},
      {'day': 15, 'label': 'Fri'},
    ];

    final weeklyBars = [0.35, 0.45, 0.30, 0.55, 0.90, (state.energyPercentage / 100.0), 0.70];
    final dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Stack(
      children: [
        // 1. Ambient warm orange radial glow at top
        Positioned(
          top: -40,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 380,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AivoColors.orange.withOpacity(0.48),
                    AivoColors.copper.withOpacity(0.18),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.45, 0.8],
                ),
              ),
            ),
          ),
        ),

        // 2. Scrollable Body
        SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand Logo & Title
                    Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                          child: const Icon(
                            Icons.wb_sunny_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Aivo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),

                    // Location & Cloud Status Row
                    Row(
                      children: [
                        if (state.isCloudConnected) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const Text(
                                  'Cloud Live',
                                  style: TextStyle(
                                    color: Color(0xFF34D399),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        // Location Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.15)),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.location_on_rounded, color: AivoColors.orangeLight, size: 13),
                              SizedBox(width: 4),
                              Text(
                                'Toronto, Ontario',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Horizontal Date Ribbon
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: days.map((item) {
                      final dayNum = item['day'] as int;
                      final isSelected = dayNum == state.selectedDay;
                      return GestureDetector(
                        onTap: () => state.setSelectedDay(dayNum),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          child: Column(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: isSelected
                                      ? const LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Color(0xFFFFA767),
                                            AivoColors.orange,
                                          ],
                                        )
                                      : null,
                                  color: isSelected ? null : Colors.white.withOpacity(0.05),
                                  border: Border.all(
                                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: AivoColors.orange.withOpacity(0.6),
                                            blurRadius: 16,
                                            spreadRadius: 2,
                                          )
                                        ]
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '$dayNum',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item['label'] as String,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : AivoColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),

                // Current Cycle Phase Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AivoColors.orangeLight,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${state.userPrediction.phaseDisplayName} • Day ${state.selectedDay} • ${state.userPrediction.predictedState}',
                      style: const TextStyle(
                        color: AivoColors.orangeBright,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Hero Recommendation Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16141B).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      // Sub-tag
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AivoColors.orangeLight,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'AI PREDICTION & RECOMMENDATION',
                            style: TextStyle(
                              color: AivoColors.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Large Title from Content Library
                      Text(
                        state.userProtocol.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Paraphrased Summary
                      Text(
                        state.userProtocol.paraphrasedSummary,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AivoColors.textSecondary,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Action tip micro-protocol
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.tips_and_updates_rounded, color: AivoColors.orangeLight, size: 12),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                state.userProtocol.actionTipForUser,
                                style: const TextStyle(
                                  color: Color(0xFFD1D0D7),
                                  fontSize: 10,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Action Chips
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildChip(Icons.play_arrow_rounded, '${state.userProtocol.durationMinutes} min'),
                          const SizedBox(width: 8),
                          _buildChip(Icons.auto_awesome, state.userProtocol.contentType),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Primary CTA: Play Now
                      GestureDetector(
                        onTap: onPlaySession,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.25),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.play_arrow_rounded, color: Colors.black, size: 20),
                              SizedBox(width: 6),
                              Text(
                                'Play Now',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Biometrics & Forecast Grid
                // Card 1: Energy Forecast
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16141B).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.flash_on_rounded, color: AivoColors.orangeLight, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'Energy Forecast',
                                style: TextStyle(
                                  color: AivoColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Icon(Icons.chevron_right_rounded, color: AivoColors.textMuted, size: 18),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${state.energyPercentage}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1,
                                ),
                              ),
                              Text(
                                '3-Day Avg Stress: ${state.userPrediction.rollingStressAvg}/10 • Sleep: ${state.userPrediction.rollingSleepAvg}h',
                                style: const TextStyle(
                                  color: AivoColors.textSecondary,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),

                          // Mini Weekly Bar Chart
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(7, (idx) {
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 9,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.06),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        width: 9,
                                        height: 38 * weeklyBars[idx],
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(6),
                                          gradient: const LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              AivoColors.copper,
                                              AivoColors.orange,
                                              AivoColors.orangeLight,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      dayLabels[idx],
                                      style: const TextStyle(
                                        color: AivoColors.textMuted,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 3 Stat Cards Row
                Row(
                  children: [
                    Expanded(
                      child: _buildSmallStatCard(
                        title: '9 minutes',
                        subtitle: 'Average session',
                        isHighlight: false,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSmallStatCard(
                        title: state.currentMood,
                        subtitle: 'Current mood',
                        isHighlight: false,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSmallStatCard(
                        title: '8:30 PM',
                        subtitle: 'Meditation Time',
                        isHighlight: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AivoColors.orangeLight, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStatCard({
    required String title,
    required String subtitle,
    required bool isHighlight,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF16141B).withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isHighlight ? AivoColors.orange : Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: AivoColors.textSecondary,
              fontSize: 10,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
