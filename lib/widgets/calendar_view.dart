import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'calendar/calendar_panel.dart';

class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 186, 187, 190),
      child: const Column(
        children: [
          SizedBox(height: 20),
          Expanded(
            child: CalendarPanel(),
          ),
        ],
      ),
    );
  }
}
