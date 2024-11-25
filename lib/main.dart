import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/calendar_provider.dart';
import 'providers/task_provider.dart';
import 'providers/completed_task_provider.dart';
import 'package:calendar_view/calendar_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider(
      controller: EventController(),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => CalendarProvider()),
          ChangeNotifierProvider(create: (context) => TaskProvider()),
          ChangeNotifierProvider(create: (context) => CompletedTaskProvider()),
        ],
        child: MaterialApp(
          title: 'Calendar App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            fontFamily: GoogleFonts.poppins().fontFamily,
            scaffoldBackgroundColor: const Color.fromARGB(255, 186, 187, 190),
          ),
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
