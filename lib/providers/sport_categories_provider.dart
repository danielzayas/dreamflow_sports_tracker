import 'package:flutter/foundation.dart';
import '../models/sport_category.dart';
import '../services/data_service.dart';

class SportCategoriesProvider with ChangeNotifier {
  final DataService _dataService = DataService();
  List<SportCategory> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<SportCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all sport categories
  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _dataService.initializeData();
      _categories = await _dataService.getSportCategories();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load sport categories: ${e.toString()}';
      notifyListeners();
    }
  }

  // Get a specific category by ID
  SportCategory? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }
}