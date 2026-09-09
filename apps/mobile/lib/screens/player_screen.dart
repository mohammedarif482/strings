import 'package:flutter/material.dart';
import '../theme/aivo_theme.dart';
import '../models/wellness_state.dart';
import '../widgets/glowing_human_silhouette.dart';
import '../widgets/dot_matrix_visualizer.dart';

class PlayerScreen extends StatefulWidget {
  final WellnessState state;
  final VoidCallback onBack;

  const PlayerScreen({
    super.key,
    required this.state,
    required this.onBack,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  String _activeNode = 'mind';
  bool _isFinished = false;

  void _handleNodeSelect(String node) {
    setState(() => _activeNode = node);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E1B25),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AivoColors.orange.withOpacity(0.3)),
        ),
        content: Text(
          node == 'mind'
            ? 'Mind Focus: Release intrusive thoughts and observe the breath.'
            : node == 'heart'
            ? 'Heart Focus: Lower heart rate variability to 65 bpm.'
            : 'Breath Focus: 4-sec inhale, 7-sec hold, 8-sec exhale.',
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  void _handleFinish() {
    setState(() => _isFinished = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E1B25),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF34D399)),
        ),
        content: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: Color(0xFF34D399), size: 18),
            SizedBox(width: 8),
            Text('Session Completed & Mind Reset!'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Ambient background glow
        Positioned(
          top: 30,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 340,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AivoColors.orangeLight.withOpacity(0.3),
                    AivoColors.copper.withOpacity(0.12),
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                // Top Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: widget.onBack,
                      child: Row(
                        children: const [
                          Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Now Playing',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: const Icon(Icons.more_horiz_rounded, color: AivoColors.textSecondary, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Central Ethereal Body Silhouette with interactive nodes
                GlowingHumanSilhouette(
                  activeNode: _activeNode,
                  onNodeSelected: _handleNodeSelect,
                ),
                const SizedBox(height: 10),

                // Track Information
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
                      'AIVO RECOMMENDATION',
                      style: TextStyle(
                        color: AivoColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                const Text(
                  'Reset Your Mind',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'A gentle guided session designed to release tension and bring your attention back to the present.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AivoColors.textSecondary,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Action chips
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildChip(Icons.play_arrow_rounded, '10 min'),
                    const SizedBox(width: 10),
                    _buildChip(Icons.auto_awesome, 'Guided'),
                  ],
                ),
                const SizedBox(height: 16),

                // Dot Matrix Audio Visualizer
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: DotMatrixVisualizer(isPlaying: widget.state.isPlaying),
                ),
                const SizedBox(height: 18),

                // Dual Action Buttons: Hold to Finish & Take a Break
                Row(
                  children: [
                    // Hold to finish
                    Expanded(
                      child: GestureDetector(
                        onTap: _handleFinish,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          decoration: BoxDecoration(
                            color: _isFinished ? const Color(0xFF34D399).withOpacity(0.15) : const Color(0xFF1B1822),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: _isFinished ? const Color(0xFF34D399) : Colors.white.withOpacity(0.1),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isFinished ? Icons.check_circle_rounded : Icons.radio_button_checked_rounded,
                                color: _isFinished ? const Color(0xFF34D399) : Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isFinished ? 'Finished' : 'Hold to finish',
                                style: TextStyle(
                                  color: _isFinished ? const Color(0xFF34D399) : Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Take a break
                    Expanded(
                      child: GestureDetector(
                        onTap: () => widget.state.togglePlay(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.2),
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
                                widget.state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: Colors.black,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.state.isPlaying ? 'Take a break' : 'Resume',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Bottom Playback Navigation Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Speed gauge
                      IconButton(
                        icon: const Icon(Icons.speed_rounded, color: AivoColors.textMuted, size: 20),
                        onPressed: () {},
                      ),

                      // Rewind 10s
                      IconButton(
                        icon: const Icon(Icons.replay_10_rounded, color: AivoColors.textMuted, size: 22),
                        onPressed: () {},
                      ),

                      // Center Glowing Amber Play/Pause
                      GestureDetector(
                        onTap: () => widget.state.togglePlay(),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AivoColors.orangeLight,
                                Color(0xFFFF5E1E),
                              ],
                            ),
                            border: Border.all(
                              color: const Color(0xFFFFA566).withOpacity(0.6),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AivoColors.orange.withOpacity(0.7),
                                blurRadius: 22,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),

                      // Forward 10s
                      IconButton(
                        icon: const Icon(Icons.forward_10_rounded, color: AivoColors.textMuted, size: 22),
                        onPressed: () {},
                      ),

                      // Equalizer
                      IconButton(
                        icon: const Icon(Icons.tune_rounded, color: AivoColors.textMuted, size: 20),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
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
}
