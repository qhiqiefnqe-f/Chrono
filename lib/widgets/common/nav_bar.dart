import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/calendar_provider.dart';
import 'custom_button.dart';
import '../../screens/task_edit_screen.dart';
import 'custom_button_effect.dart';

class NavBar extends StatelessWidget {
  final VoidCallback onTodayTap;
  final VoidCallback onCalendarTap;
  final int currentIndex;

  const NavBar({
    super.key,
    required this.onTodayTap,
    required this.onCalendarTap,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          // 左侧导航按钮组
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _buildNavButton(
                  text: 'Today',
                  icon: Icons.today,
                  isActive: currentIndex == 0,
                  onPressed: onTodayTap,
                ),
                _buildNavButton(
                  text: 'Calendar',
                  icon: Icons.calendar_month,
                  isActive: currentIndex == 1,
                  onPressed: onCalendarTap,
                ),
              ],
            ),
          ),
          const Spacer(),
          CustomButtonEffect(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskEditScreen(),
                ),
              );
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required String text,
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isActive ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isActive ? Colors.white : Colors.black,
                ),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
