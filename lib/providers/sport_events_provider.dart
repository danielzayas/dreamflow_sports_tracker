import 'package:flutter/foundation.dart';
import '../models/sport_event.dart';
import '../services/data_service.dart';
import '../widgets/event_filter.dart';

class SportEventsProvider with ChangeNotifier {
  final DataService _dataService = DataService();
  List<SportEvent> _liveEvents = [];
  List<SportEvent> _upcomingEvents = [];
  List<SportEvent> _filteredLiveEvents = [];
  List<SportEvent> _filteredUpcomingEvents = [];
  
  // Use separate flags for initial loading vs. refreshing
  bool _isInitialLoadingLive = false;
  bool _isInitialLoadingUpcoming = false;
  bool _isRefreshingLive = false;
  bool _isRefreshingUpcoming = false;
  
  String? _liveError;
  String? _upcomingError;
  List<FilterOption> _selectedFilters = [FilterOption(id: 'all', name: 'All Leagues', type: 'all')];
  List<FilterOption> _filterOptions = [];

  List<SportEvent> get liveEvents => _filteredLiveEvents;
  List<SportEvent> get upcomingEvents => _filteredUpcomingEvents;
  
  // Only expose the initial loading flags to the UI
  bool get isLoadingLive => _isInitialLoadingLive;
  bool get isLoadingUpcoming => _isInitialLoadingUpcoming;
  
  // Add getters for refresh state if needed
  bool get isRefreshingLive => _isRefreshingLive;
  bool get isRefreshingUpcoming => _isRefreshingUpcoming;
  
  String? get liveError => _liveError;
  String? get upcomingError => _upcomingError;
  List<FilterOption> get selectedFilters => _selectedFilters;
  List<FilterOption> get filterOptions => _filterOptions;

  // Initialize the provider with data
  Future<void> initialize() async {
    await _dataService.initializeData();
    await _initialLoadLiveEvents();
    await _initialLoadUpcomingEvents();
    await generateFilterOptions();
  }

  // Initial load for live events - shows loading indicator
  Future<void> _initialLoadLiveEvents() async {
    _isInitialLoadingLive = true;
    _liveError = null;
    notifyListeners();

    try {
      _liveEvents = await _dataService.getLiveEvents();
      _applyFilters();
      _isInitialLoadingLive = false;
      notifyListeners();
    } catch (e) {
      _isInitialLoadingLive = false;
      _liveError = 'Failed to load live events: ${e.toString()}';
      notifyListeners();
    }
  }

  // Initial load for upcoming events - shows loading indicator
  Future<void> _initialLoadUpcomingEvents() async {
    _isInitialLoadingUpcoming = true;
    _upcomingError = null;
    notifyListeners();

    try {
      _upcomingEvents = await _dataService.getUpcomingEvents();
      _applyFilters();
      _isInitialLoadingUpcoming = false;
      notifyListeners();
    } catch (e) {
      _isInitialLoadingUpcoming = false;
      _upcomingError = 'Failed to load upcoming events: ${e.toString()}';
      notifyListeners();
    }
  }
  
  // Refresh all data from ESPN APIs
  Future<void> refreshFromEspnApi() async {
    // Set refreshing flags without clearing existing data
    _isRefreshingLive = true;
    _isRefreshingUpcoming = true;
    _liveError = null;
    _upcomingError = null;
    notifyListeners(); // Let UI know we're refreshing

    try {
      // Fetch fresh data from ESPN APIs
      final espnEvents = await _dataService.refreshEventsFromEspn();
      
      // Update live and upcoming events after successful refresh
      _liveEvents = await _dataService.getLiveEvents();
      _upcomingEvents = await _dataService.getUpcomingEvents();
      
      // Apply filters and update filter options with new data
      _applyFilters();
      await generateFilterOptions();
      
      // Clear flags and notify listeners
      _isRefreshingLive = false;
      _isRefreshingUpcoming = false;
      notifyListeners();
    } catch (e) {
      _isRefreshingLive = false;
      _isRefreshingUpcoming = false;
      _liveError = 'Failed to refresh data from ESPN: ${e.toString()}';
      _upcomingError = _liveError;
      notifyListeners();
    }
  }
  
  // Refresh live events - keeps showing old data while fetching
  Future<void> refreshLiveEvents() async {
    // Don't clear existing data or show loading indicator
    _isRefreshingLive = true;
    _liveError = null;
    // Don't notify listeners here to avoid UI flicker

    try {
      final newLiveEvents = await _dataService.getLiveEvents();
      _liveEvents = newLiveEvents;
      _applyFilters();
      _isRefreshingLive = false;
      notifyListeners(); // Only notify once with the new data
    } catch (e) {
      _isRefreshingLive = false;
      _liveError = 'Failed to refresh live events: ${e.toString()}';
      notifyListeners();
    }
  }

  // Refresh upcoming events - keeps showing old data while fetching
  Future<void> refreshUpcomingEvents() async {
    // Don't clear existing data or show loading indicator
    _isRefreshingUpcoming = true;
    _upcomingError = null;
    // Don't notify listeners here to avoid UI flicker

    try {
      final newUpcomingEvents = await _dataService.getUpcomingEvents();
      _upcomingEvents = newUpcomingEvents;
      _applyFilters();
      _isRefreshingUpcoming = false;
      notifyListeners(); // Only notify once with the new data
    } catch (e) {
      _isRefreshingUpcoming = false;
      _upcomingError = 'Failed to refresh upcoming events: ${e.toString()}';
      notifyListeners();
    }
  }

  // Generate filter options
  Future<void> generateFilterOptions() async {
    try {
      final categories = await _dataService.getSportCategories();
      final allEvents = [..._liveEvents, ..._upcomingEvents];
      _filterOptions = EventFilter.generateFilterOptions(categories, allEvents);
      notifyListeners();
    } catch (e) {
      // Handle error
      print('Error generating filter options: $e');
    }
  }

  // Toggle a filter on/off
  void toggleFilter(FilterOption filter, bool isSelected) {
    if (filter.id == 'all' && isSelected) {
      // If 'All Leagues' is selected, clear all other filters
      _selectedFilters = [filter];
    } else if (isSelected) {
      // If another filter is selected, remove 'All Leagues' if it exists
      _selectedFilters.removeWhere((f) => f.id == 'all');
      
      // For exclusion filters, we need to handle conflicts
      if (filter.type == 'exclude_league') {
        // If this is an exclusion filter, remove any inclusion filter for the same league
        final leagueId = filter.leagueIds.first;
        _selectedFilters.removeWhere((f) => 
          (f.type == 'league' || f.type == 'include_leagues') && 
          f.leagueIds.contains(leagueId));
      } else if (filter.type == 'league' || filter.type == 'include_leagues') {
        // If this is an inclusion filter, remove any exclusion filters for the same leagues
        for (final leagueId in filter.leagueIds) {
          _selectedFilters.removeWhere((f) => 
            f.type == 'exclude_league' && 
            f.leagueIds.contains(leagueId));
        }
      }
      
      // Add the new filter
      _selectedFilters.add(filter);
    } else {
      // Remove the filter if it's deselected
      _selectedFilters.removeWhere((f) => f.id == filter.id);
    }
    
    // If no filters are left, default to 'All Leagues'
    if (_selectedFilters.isEmpty) {
      _selectedFilters = [_filterOptions.first]; // 'All Leagues' is always first
    }
    
    _applyFilters();
    notifyListeners();
  }

  // Apply filters to events
  void _applyFilters() {
    _filteredLiveEvents = EventFilter.filterEvents(_liveEvents, _selectedFilters);
    _filteredUpcomingEvents = EventFilter.filterEvents(_upcomingEvents, _selectedFilters);
  }

  // Refresh all data without showing loading indicators
  Future<void> refreshData() async {
    try {
      // Try to refresh from ESPN APIs first
      await refreshFromEspnApi();
    } catch (e) {
      // If ESPN refresh fails, fall back to refreshing from local storage
      print('ESPN refresh failed, falling back to local storage: $e');
      // Run both refresh operations concurrently
      await Future.wait([
        refreshLiveEvents(),
        refreshUpcomingEvents(),
      ]);
      
      // After refreshing data, also update filter options
      await generateFilterOptions();
    }
  }

  // Get a specific event by ID
  SportEvent? getEventById(String id) {
    try {
      final allEvents = [..._liveEvents, ..._upcomingEvents];
      return allEvents.firstWhere((event) => event.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Clear all filters and reset to 'All Leagues'
  void clearFilters() {
    _selectedFilters = [_filterOptions.first]; // 'All Leagues' is always first
    _applyFilters();
    notifyListeners();
  }
}