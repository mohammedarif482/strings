import 'package:flutter/material.dart';
import 'screens/today_tab.dart';
import 'screens/session_tab.dart';
import 'screens/insights_tab.dart';

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
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: const [
            TodayTab(),
            SessionTab(),
            InsightsTab(),
          ],
        ),
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
