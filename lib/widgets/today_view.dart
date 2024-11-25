import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'today/time_display.dart';
import 'today/tasks_panel.dart';
import 'today/tasks_chart.dart';

class TodayView extends StatefulWidget {
  const TodayView({super.key});

  @override
  State<TodayView> createState() => _TodayViewState();
}

class _TodayViewState extends State<TodayView> {
  final PanelController _panelController = PanelController();
  double _slideProgress = 0.0;
  bool _wasAtTop = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_wasAtTop) {
        _panelController.open();
      } else {
        _panelController.close();
      }
    });
  }

  void _onPanelSlide(double progress) {
    setState(() {
      _slideProgress = progress;
      _wasAtTop = progress > 0.5;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Container(
          color: const Color.fromARGB(255, 186, 187, 190),
          child: Column(
            children: [
              const SizedBox(height: 20),
              TimeDisplay(slideProgress: _slideProgress),
              const TasksChart(),
            ],
          ),
        ),
        SlidingUpPanel(
          controller: _panelController,
          minHeight: screenHeight / 5,
          maxHeight: screenHeight * 3 / 5,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          panel: TasksPanel(
            panelController: _panelController,
            slideProgress: _slideProgress,
          ),
          onPanelSlide: _onPanelSlide,
          body: Container(),
        ),
      ],
    );
  }
}
