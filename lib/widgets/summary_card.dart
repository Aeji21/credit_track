import 'package:flutter/material.dart';
import '../main.dart';

class SummaryCard extends StatelessWidget {
  final String label;
  final String amount;
  final String subtitle;
  final Color color;
  final IconData icon;

  const SummaryCard({
    super.key,
    required this.label,
    required this.amount,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.18), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 11, color: AppTheme.text2,
                      fontWeight: FontWeight.w500, letterSpacing: 0.4)),
              Icon(icon, color: color.withOpacity(0.6), size: 20),
            ],
          ),
          const SizedBox(height: 10),
          Text(amount,
              style: TextStyle(fontFamily: 'Syne', fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 6),
          Text(subtitle, style: TextStyle(fontSize: 11, color: color.withOpacity(0.7))),
        ],
      ),
    );
  }
}
