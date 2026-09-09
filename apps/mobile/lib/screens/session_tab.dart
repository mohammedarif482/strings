import 'package:flutter/material.dart';

class SessionTab extends StatelessWidget {
  const SessionTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.play_circle_fill, size: 64, color: Color(0xFFFF6B2C)),
          SizedBox(height: 16),
          Text(
            'Guided Biometric Session',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            'Physiological Sigh & Parasympathetic Realignment',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
