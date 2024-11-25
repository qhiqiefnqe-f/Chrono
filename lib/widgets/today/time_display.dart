import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';

class TimeDisplay extends StatelessWidget {
  final double slideProgress;

  const TimeDisplay({
    super.key,
    required this.slideProgress,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final screenWidth = MediaQuery.of(context).size.width;
    final uncompletedTasks = context.watch<TaskProvider>().todayTasks.length;

    // 计算动画位置
    final leftSectionOffset = slideProgress * (screenWidth / 3 - 20);
    final rightSectionOffset = slideProgress * screenWidth;

    // 计算装饰线条和任务计数的位置
    final decorationLineOffset =
        (-screenWidth * (1 - slideProgress)) + (screenWidth / 5);
    final tasksCountOffset = decorationLineOffset - 50; // 任务计数在线条左侧50px处

    return Container(
      height: 180,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        children: [
          // 任务计数
          Positioned(
            left: tasksCountOffset,
            top: 12, // 与线条对齐
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end, // 右对齐
              children: [
                Text(
                  uncompletedTasks.toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                  ),
                ),
                const Text(
                  'tasks',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.0,
                  ),
                ),
                const Text(
                  'left',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
          // 装饰线条
          Positioned(
            left: decorationLineOffset,
            top: 12,
            height: 140,
            child: Container(
              width: 9,
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
            ),
          ),
          // 左侧部分（日期、时间、月份）
          Transform.translate(
            offset: Offset(leftSectionOffset, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('EEEE').format(now),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      DateFormat('h:mm').format(now),
                      style: const TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('a').format(now),
                      style: const TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  DateFormat('MMM').format(now).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          // 右侧部分（时区信息）
          Transform.translate(
            offset: Offset(rightSectionOffset, 0),
            child: Row(
              children: [
                const Spacer(),
                Container(
                  width: 1,
                  height: 120,
                  color: Colors.black,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTimeZone('Local', now),
                    const SizedBox(height: 10),
                    _buildTimeZone('UTC', now.toUtc()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeZone(String label, DateTime time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          DateFormat('HH:mm').format(time),
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
