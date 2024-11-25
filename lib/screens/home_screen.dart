import 'package:flutter/material.dart';
import '../widgets/common/nav_bar.dart';
import '../widgets/today_view.dart';
import '../widgets/calendar_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            NavBar(
              currentIndex: _tabController.index,
              onTodayTap: () {
                _tabController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              onCalendarTap: () {
                _tabController.animateTo(
                  1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: const [
                  TodayView(),
                  CalendarView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
