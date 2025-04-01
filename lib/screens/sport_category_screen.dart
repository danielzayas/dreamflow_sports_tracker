// This file is kept for compatibility but is no longer used.
// The home screen now handles all event listing functionality.

import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../models/sport_category.dart';
import '../providers/sport_events_provider.dart';
import '../widgets/event_filter.dart';

class SportCategoryScreen extends StatelessWidget {
  final SportCategory category;

  const SportCategoryScreen({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This screen is no longer used
    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
      ),
      body: const Center(
        child: Text('This screen is deprecated. Please use the main home screen.'),
      ),
    );
  }
}