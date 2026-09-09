import 'package:flutter/material.dart';
import '../theme/aivo_theme.dart';
import '../models/wellness_state.dart';
import '../widgets/arc_gauge.dart';
import '../widgets/partner_pair_sheet.dart';
import '../widgets/privacy_settings_sheet.dart';

class InsightsScreen extends StatelessWidget {
  final WellnessState state;

  const InsightsScreen({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    // 4 rows x 7 days capsule states
    // 1: reached, 2: partial, 0: none
    final matrixData = [
      [1, 2, 0, 1, 0, 0, 1],
      [1, 1, 0, 2, 1, 1, 1],
      [0, 1, 1, 0, 1, 1, 2],
      [0, 0, 1, 1, 0, 2, 0],
    ];

    return Stack(
      children: [
        // Ambient background glow
        Positioned(
          top: -20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 360,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AivoColors.orange.withOpacity(0.4),
                    AivoColors.copper.withOpacity(0.15),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.45, 0.8],
                ),
              ),
            ),
          ),
        ),

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
                    const Text(
                      'AI Insights',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),

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
                const SizedBox(height: 10),

                // Master Gauge / Score Display
                Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 145,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ArcGauge(score: state.wellnessScore),
                            Positioned(
                              top: 52,
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        '${state.wellnessScore}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 38,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -1,
                                        ),
                                      ),
                                      const Text(
                                        '/100',
                                        style: TextStyle(
                                          color: AivoColors.textSecondary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.06),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.trending_up_rounded, color: AivoColors.orangeLight, size: 12),
                                        SizedBox(width: 3),
                                        Text(
                                          '12% from last week',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Your wellness score',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Your mindfulness habits improved, creating greater balance and emotional stability this week.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AivoColors.textSecondary,
                            fontSize: 11,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Card 2: Mindfulness Activity Matrix
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
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
                              Icon(Icons.bubble_chart_rounded, color: AivoColors.orangeLight, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'Mindfulness Activity',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Row(
                              children: const [
                                Text(
                                  'Last Month',
                                  style: TextStyle(
                                    color: AivoColors.textSecondary,
                                    fontSize: 10,
                                  ),
                                ),
                                SizedBox(width: 2),
                                Icon(Icons.keyboard_arrow_down_rounded, color: AivoColors.textMuted, size: 12),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Capsule rows
                      Column(
                        children: matrixData.map((row) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: row.map((val) {
                                return Expanded(
                                  child: Container(
                                    height: 14,
                                    margin: const EdgeInsets.symmetric(horizontal: 2),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7),
                                      color: val == 1
                                          ? AivoColors.peach
                                          : val == 2
                                          ? Colors.transparent
                                          : Colors.white.withOpacity(0.04),
                                      border: val == 2
                                          ? Border.all(color: Colors.white.withOpacity(0.4), style: BorderStyle.solid)
                                          : null,
                                      boxShadow: val == 1
                                          ? [
                                              BoxShadow(
                                                color: AivoColors.peach.withOpacity(0.4),
                                                blurRadius: 4,
                                              )
                                            ]
                                          : null,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),

                      // Legend
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLegendItem(AivoColors.peach, 'Goal reached', isOutline: false),
                          _buildLegendItem(Colors.white.withOpacity(0.5), 'Partial', isOutline: true),
                          _buildLegendItem(Colors.white.withOpacity(0.12), 'No activity', isOutline: false),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Card 3: Daily Average Heart Rate Range
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'DAILY AVERAGE',
                                style: TextStyle(
                                  color: AivoColors.textSecondary,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: const [
                                  Text(
                                    '76',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    'BPM',
                                    style: TextStyle(
                                      color: AivoColors.orange,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: const [
                              Text(
                                'Last reading',
                                style: TextStyle(
                                  color: AivoColors.textSecondary,
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                '2 min ago',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Heart Rate Slider Track with Floating Heart Badge
                      LayoutBuilder(
                        builder: (context, constraints) {
                          const minHR = 54;
                          const maxHR = 98;
                          final currHR = state.heartRate;
                          final pct = ((currHR - minHR) / (maxHR - minHR)).clamp(0.0, 1.0);
                          final badgeLeft = (constraints.maxWidth * pct) - 24;

                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Track line
                              Container(
                                height: 6,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  gradient: const LinearGradient(
                                    colors: [
                                      AivoColors.copper,
                                      AivoColors.orange,
                                      AivoColors.orangeBright,
                                    ],
                                  ),
                                ),
                              ),

                              // Floating Heart Badge
                              Positioned(
                                top: -11,
                                left: badgeLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AivoColors.orange,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white.withOpacity(0.4)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AivoColors.orange.withOpacity(0.8),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      )
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.favorite_rounded, color: Colors.white, size: 10),
                                      const SizedBox(width: 3),
                                      Text(
                                        '$currHR',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      // Range bounds
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Lowest 54 ↓', style: TextStyle(color: AivoColors.textSecondary, fontSize: 10)),
                          Text('Peak 98 ↑', style: TextStyle(color: AivoColors.textSecondary, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Card 4: Partner Sync / Couple Nudge Card (Dynamic Paired & Unpaired State)
                if (!state.isPaired) ...[
                  // 1. UNPAIRED STATE: Connect with Partner CTA & Scanner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF191622).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AivoColors.orange.withOpacity(0.35)),
                      boxShadow: [
                        BoxShadow(
                          color: AivoColors.orange.withOpacity(0.12),
                          blurRadius: 24,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [AivoColors.orange, Color(0xFFFF5E1E)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AivoColors.orange.withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.people_alt_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Connect with Your Partner',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Sync predictive biological windows and support each other smoothly. Intimate cycle days and raw scores remain strictly private.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AivoColors.textSecondary,
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (ctx) => PartnerPairSheet(state: state),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 13),
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.qr_code_rounded, color: Colors.white, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'Invite Partner / Scan QR Code',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
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
                ] else ...[
                  // 2. PAIRED STATE: Active Sync Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1925).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AivoColors.orange.withOpacity(0.25)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [AivoColors.orange, AivoColors.orangeLight],
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    state.partnerUser.name.isNotEmpty ? state.partnerUser.name[0] : 'P',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Partner Status: ${state.partnerUser.name}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      state.privacySettings.shareCyclePhaseDetails
                                          ? 'Synced Wearable • Day ${state.partnerPrediction.cycleDay} (${state.partnerPrediction.phaseDisplayName})'
                                          : 'Synced Partner • Privacy Protected',
                                      style: const TextStyle(
                                        color: AivoColors.orangeBright,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                // Privacy Settings Button
                                GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (ctx) => PrivacySettingsSheet(state: state),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.06),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.shield_outlined, color: Colors.white70, size: 14),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AivoColors.orange.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AivoColors.orange.withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    state.partnerPrediction.combinedStressIndex > 0.60
                                        ? 'Cortisol Alert'
                                        : 'Balanced Recovery',
                                    style: const TextStyle(
                                      color: AivoColors.orangeBright,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Research-backed partner nudge template
                        Text(
                          state.formattedPartnerNudgeTemplate,
                          style: const TextStyle(
                            color: Color(0xFFD1D0D7),
                            fontSize: 11,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Research source reference
                        Row(
                          children: [
                            const Icon(Icons.menu_book_rounded, color: AivoColors.textSecondary, size: 11),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                state.partnerProtocol.sourceReference,
                                style: const TextStyle(
                                  color: AivoColors.textSecondary,
                                  fontSize: 9,
                                  fontStyle: FontStyle.italic,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Primary Action: Send Nudge Button
                        GestureDetector(
                          onTap: () {
                            state.sendPartnerNudge();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color(0xFF1E1B25),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: const BorderSide(color: Color(0xFF34D399)),
                                ),
                                content: Row(
                                  children: [
                                    const Icon(Icons.favorite_rounded, color: Colors.pinkAccent, size: 18),
                                    const SizedBox(width: 8),
                                    Text('Supportive Nudge Sent to ${state.partnerUser.name}! ♥'),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: LinearGradient(
                                colors: state.partnerNudgeSent
                                    ? const [Color(0xFF10B981), Color(0xFF0D9488)]
                                    : const [AivoColors.orange, Color(0xFFFF5E1E)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (state.partnerNudgeSent ? const Color(0xFF10B981) : AivoColors.orange).withOpacity(0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  state.partnerNudgeSent ? Icons.check_circle_rounded : Icons.send_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  state.partnerNudgeSent
                                      ? 'Nudge Sent to ${state.partnerUser.name}! ♥'
                                      : 'Send Supportive Nudge',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Tap-Back Support Reactions
                        if (state.partnerNudgeSent) ...[
                          const SizedBox(height: 10),
                          const Text(
                            'Quick Support Reaction:',
                            style: TextStyle(color: AivoColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 6),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: [
                                _buildReactionChip(
                                  text: "I've got dinner covered tonight ❤️",
                                  isSelected: state.lastReactionSent == "I've got dinner covered tonight ❤️",
                                  onTap: () => state.sendSupportReaction("I've got dinner covered tonight ❤️"),
                                ),
                                const SizedBox(width: 6),
                                _buildReactionChip(
                                  text: "Taking chores off your plate 🌿",
                                  isSelected: state.lastReactionSent == "Taking chores off your plate 🌿",
                                  onTap: () => state.sendSupportReaction("Taking chores off your plate 🌿"),
                                ),
                                const SizedBox(width: 6),
                                _buildReactionChip(
                                  text: "Quiet evening together 🕯️",
                                  isSelected: state.lastReactionSent == "Quiet evening together 🕯️",
                                  onTap: () => state.sendSupportReaction("Quiet evening together 🕯️"),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Interactive Feedback Row (Helpful / Not quite)
                        if (state.partnerNudgeSent) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white.withOpacity(0.06)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Was this tip helpful?',
                                  style: TextStyle(
                                    color: AivoColors.textSecondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => state.logNudgeFeedback(true),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: state.lastNudgeFeedback == true
                                              ? const Color(0xFF10B981).withOpacity(0.2)
                                              : Colors.white.withOpacity(0.06),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: state.lastNudgeFeedback == true
                                                ? const Color(0xFF34D399)
                                                : Colors.white.withOpacity(0.1),
                                          ),
                                        ),
                                        child: Row(
                                          children: const [
                                            Icon(Icons.thumb_up_rounded, color: Color(0xFF34D399), size: 11),
                                            SizedBox(width: 4),
                                            Text('Helpful', style: TextStyle(color: Colors.white, fontSize: 10)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: () => state.logNudgeFeedback(false),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: state.lastNudgeFeedback == false
                                              ? Colors.amber.withOpacity(0.2)
                                              : Colors.white.withOpacity(0.06),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: state.lastNudgeFeedback == false
                                                ? Colors.amberAccent
                                                : Colors.white.withOpacity(0.1),
                                          ),
                                        ),
                                        child: Row(
                                          children: const [
                                            Icon(Icons.thumb_down_rounded, color: Colors.amberAccent, size: 11),
                                            SizedBox(width: 4),
                                            Text('Not quite', style: TextStyle(color: Colors.white, fontSize: 10)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label, {required bool isOutline}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: isOutline ? Colors.transparent : color,
            border: isOutline ? Border.all(color: color) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: AivoColors.textSecondary,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Widget _buildReactionChip({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AivoColors.orange.withOpacity(0.25) : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AivoColors.orangeBright : Colors.white.withOpacity(0.12),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
