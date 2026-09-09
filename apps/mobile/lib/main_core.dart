import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const AivoApp());
}

class AivoApp extends StatelessWidget {
  const AivoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aivo Predictive Wellness',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0B0E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF6B2C),
          surface: Color(0xFF16141B),
        ),
      ),
      home: const MainDashboard(),
    );
  }
}

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background ambient glow
          Positioned(
            top: -100,
            left: MediaQuery.of(context).size.width * 0.2,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF6B2C).withOpacity(0.18),
                boxShadow: const [
                  BoxShadow(color: Color(0xFFFF6B2C), blurRadius: 120, spreadRadius: 40)
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: IndexedStack(
              index: _selectedIndex,
              children: const [
                TodayTab(),
                Center(child: Text("Active Session View", style: TextStyle(color: Colors.white))),
                InsightsTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: const Color(0xFF121015),
        selectedItemColor: const Color(0xFFFF6B2C),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Today'),
          BottomNavigationBarItem(icon: Icon(Icons.play_circle_fill), label: 'Session'),
          BottomNavigationBarItem(icon: Icon(Icons.bubble_chart), label: 'Insights'),
        ],
      ),
    );
  }
}

// TODAY TAB (SCREEN 1)
class TodayTab extends StatelessWidget {
  const TodayTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        // Top Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.wb_sunny_outlined, color: Color(0xFFFF6B2C)),
                SizedBox(width: 8),
                Text('Aivo', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('📍 Toronto, Ontario', style: TextStyle(fontSize: 12, color: Colors.grey)),
            )
          ],
        ),
        const SizedBox(height: 20),

        // Date Ribbon
        SizedBox(
          height: 70,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildDateTile("10", "Sun", false),
              _buildDateTile("11", "Mon", false),
              _buildDateTile("12", "Tue", true),
              _buildDateTile("13", "Wed", false),
              _buildDateTile("14", "Thu", false),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Hero Card (Prediction + Protocol)
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAlignment.start,
            children: [
              const Text('• AIVO RECOMMENDATION', style: TextStyle(color: Color(0xFFFF6B2C), fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text('Reset Your Mind', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 6),
              const Text(
                'A gentle guided session designed to release tension based on your late-luteal cortisol prediction.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildChip("10 min"),
                  const SizedBox(width: 8),
                  _buildChip("Guided"),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.vertical(14),
                  ),
                  onPressed: () {},
                  child: const Text('Play Now', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateTile(String day, String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFFF6B2C) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(day, style: TextStyle(color: isActive ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: isActive ? Colors.black80 : Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
    );
  }
}

// INSIGHTS & PARTNER TAB (SCREEN 3)
class InsightsTab extends StatelessWidget {
  const InsightsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        const Text("AI Insights", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 20),
        
        // Gauge / Score Card
        GlassCard(
          child: Column(
            children: [
              const Text("82 / 100", style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Color(0xFFFF6B2C))),
              const Text("↗ 12% from last week", style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
              const SizedBox(height: 12),
              const Text("Your wellness score indicates high emotional balance this week.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Couple Layer Nudge Card
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.favorite, color: Color(0xFFFF6B2C), size: 18),
                  SizedBox(width: 8),
                  Text("Partner Sync • Sarah", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                "Sarah is likely to enter a high-cortisol state Thursday. Clear evening tasks to support her.",
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF6B2C),
                  side: const BorderSide(color: Color(0xFFFF6B2C)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () {},
                child: const Text("Send Supportive Nudge"),
              )
            ],
          ),
        )
      ],
    );
  }
}

// REUSABLE GLASSMORPHIC CARD
class GlassCard extends StatelessWidget {
  final Widget child;
  const GlassCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }
}
