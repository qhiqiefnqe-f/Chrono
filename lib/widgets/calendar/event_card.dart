import 'package:flutter/material.dart';
import '../common/custom_card.dart';
import '../common/custom_text.dart';

class EventCard extends StatelessWidget {
  final String title;
  final String time;
  final Color color;

  const EventCard({
    super.key,
    required this.title,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      backgroundColor: color.withOpacity(0.2),
      borderColor: color.withOpacity(0.3),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: title,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 5),
                CustomText.body(
                  text: time,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
