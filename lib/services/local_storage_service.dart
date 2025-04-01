import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sport_category.dart';
import '../models/sport_event.dart';

class LocalStorageService {
  static const String _categoriesKey = 'sport_categories';
  static const String _eventsKey = 'sport_events';

  // Save sport categories to local storage
  Future<void> saveSportCategories(List<SportCategory> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = categories.map((category) => jsonEncode(category.toJson())).toList();
    await prefs.setStringList(_categoriesKey, categoriesJson);
  }

  // Load sport categories from local storage
  Future<List<SportCategory>> loadSportCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = prefs.getStringList(_categoriesKey) ?? [];
    return categoriesJson
        .map((categoryJson) => SportCategory.fromJson(jsonDecode(categoryJson)))
        .toList();
  }

  // Save sport events to local storage
  Future<void> saveSportEvents(List<SportEvent> events) async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = events.map((event) => jsonEncode(event.toJson())).toList();
    await prefs.setStringList(_eventsKey, eventsJson);
  }

  // Load sport events from local storage
  Future<List<SportEvent>> loadSportEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = prefs.getStringList(_eventsKey) ?? [];
    return eventsJson
        .map((eventJson) => SportEvent.fromJson(jsonDecode(eventJson)))
        .toList();
  }

  // Clear all data
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}