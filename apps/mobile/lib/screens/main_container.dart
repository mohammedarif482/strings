import 'package:flutter/material.dart';
import '../models/wellness_state.dart';
import '../theme/aivo_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/checkin_bottom_sheet.dart';
import 'dashboard_screen.dart';
import 'player_screen.dart';
import 'insights_screen.dart';

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _activeTab = 0;
  final WellnessState _state = WellnessState();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _state,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: AivoColors.background,
          body: Stack(
            children: [
              // Screen Body
              IndexedStack(
                index: _activeTab,
                children: [
                  DashboardScreen(
                    state: _state,
                    onPlaySession: () => setState(() => _activeTab = 1),
                  ),
                  PlayerScreen(
                    state: _state,
                    onBack: () => setState(() => _activeTab = 0),
                  ),
                  InsightsScreen(
                    state: _state,
                  ),
                  _buildProfileScreen(),
                ],
              ),

              // Floating Bottom Nav Bar (hidden in active player mode, visible in all others)
              if (_activeTab != 1)
                BottomNavBar(
                  activeIndex: _activeTab,
                  onTabSelected: (index) => setState(() => _activeTab = index),
                  onOpenCheckIn: () => CheckInBottomSheet.show(context, _state),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileScreen() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AivoColors.orange, AivoColors.orangeLight],
                  ),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'A',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Dr. Alex Rivera',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Biological Profile • Toronto, ON',
                style: TextStyle(
                  color: AivoColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AivoColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Synced Partner',
                      style: TextStyle(color: AivoColors.textSecondary, fontSize: 11),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Sarah • Oura Ring Gen 3 Connected',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    Divider(color: Colors.white10, height: 20),
                    Text(
                      'Predictive Biological Model',
                      style: TextStyle(color: AivoColors.textSecondary, fontSize: 11),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Late-Luteal Cortisol & HRV Synchronization',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
