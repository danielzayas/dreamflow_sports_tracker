import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/theme.dart';
import 'providers/sport_events_provider.dart';
import 'screens/home_screen.dart';

class SportsTrackerApp extends StatelessWidget {
  const SportsTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SportEventsProvider()),
      ],
      child: MaterialApp(
        title: 'Sports Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}