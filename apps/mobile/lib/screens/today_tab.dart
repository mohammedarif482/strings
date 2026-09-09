import 'package:flutter/material.dart';

class TodayTab extends StatelessWidget {
  const TodayTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
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
              child: const Text('📍 Toronto, ON', style: TextStyle(fontSize: 12, color: Colors.grey)),
            )
          ],
        ),
        const SizedBox(height: 24),

        // Hero Card
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
              const Text('• AIVO RECOMMENDATION', style: TextStyle(color: Color(0xFFFF6B2C), fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text('Reset Your Mind', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 6),
              const Text(
                'A gentle guided protocol designed to release tension based on your late-luteal cortisol prediction.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
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
                  child: const Text('Start Protocol', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
