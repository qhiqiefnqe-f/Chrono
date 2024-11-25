import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../common/custom_text.dart';

class TasksChart extends StatelessWidget {
  const TasksChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 300,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText.subtitle(text: 'Weekly Performance'),
          const SizedBox(height: 5),
          Row(
            children: [
              _buildLegendItem('On Time', const Color(0xFF89AB8C)),
              const SizedBox(width: 20),
              _buildLegendItem('Delayed', const Color(0xFFAD8B9F)),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  drawHorizontalLine: true,
                  horizontalInterval: 1,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300],
                      strokeWidth: 1,
                      dashArray: [5, 5], // 添加虚线效果
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300],
                      strokeWidth: 1,
                      dashArray: [5, 5], // 添加虚线效果
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final date = DateTime.now().subtract(
                          Duration(days: 6 - value.toInt()),
                        );
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('d').format(date),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    left: BorderSide(color: Colors.grey[400]!),
                    bottom: BorderSide(color: Colors.grey[400]!),
                  ),
                ),
                lineBarsData: [
                  // 准时完成的任务
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 3),
                      const FlSpot(1, 2),
                      const FlSpot(2, 4),
                      const FlSpot(3, 3),
                      const FlSpot(4, 5),
                      const FlSpot(5, 3),
                      const FlSpot(6, 4),
                    ],
                    isCurved: true,
                    color: const Color(0xFF89AB8C),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: const Color(0xFF89AB8C),
                        );
                      },
                    ),
                  ),
                  // 延迟完成的任务
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 1),
                      const FlSpot(1, 3),
                      const FlSpot(2, 2),
                      const FlSpot(3, 1),
                      const FlSpot(4, 2),
                      const FlSpot(5, 1),
                      const FlSpot(6, 2),
                    ],
                    isCurved: true,
                    color: const Color(0xFFAD8B9F),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: const Color(0xFFAD8B9F),
                        );
                      },
                    ),
                  ),
                ],
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
