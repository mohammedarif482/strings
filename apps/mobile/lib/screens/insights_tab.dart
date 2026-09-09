import 'package:flutter/material.dart';

class InsightsTab extends StatelessWidget {
  const InsightsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        const Text("AI Insights", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 20),
        
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: const Column(
            children: [
              Text("82 / 100", style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Color(0xFFFF6B2C))),
              Text("↗ 12% from last week", style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
              SizedBox(height: 12),
              Text(
                "Your wellness score indicates high emotional balance this week.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
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
                "Sarah is likely entering a high-cortisol phase tomorrow. Clear evening tasks to support her.",
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
