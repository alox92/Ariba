import 'package:flutter/material.dart';

/// A simple card widget for displaying a chart placeholder.
class ChartCard extends StatelessWidget {
  final String title;

  const ChartCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2C2F3A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Chart Placeholder',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
