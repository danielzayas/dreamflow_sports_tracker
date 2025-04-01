import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../models/sport_category.dart';
import '../models/sport_event.dart';

class FilterOption {
  final String id;
  final String name;
  final String type; // 'all', 'league', 'include_leagues', 'exclude_league'
  final List<String> leagueIds; // List of league IDs to include or exclude
  final bool isExclusion; // Whether this is an exclusion filter

  FilterOption({
    required this.id,
    required this.name,
    required this.type,
    this.leagueIds = const [],
    this.isExclusion = false,
  });
}

class EventFilter extends StatelessWidget {
  final List<FilterOption> filterOptions;
  final List<FilterOption> selectedFilters;
  final Function(FilterOption, bool) onFilterToggled;

  const EventFilter({
    Key? key,
    required this.filterOptions,
    required this.selectedFilters,
    required this.onFilterToggled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filterOptions.length,
        itemBuilder: (context, index) {
          final filter = filterOptions[index];
          final isSelected = selectedFilters.any((f) => f.id == filter.id);
          
          // If all is selected, we disable other filters
          final isAllSelected = selectedFilters.any((f) => f.id == 'all');
          final isDisabled = filter.id != 'all' && isAllSelected;
          
          Color chipColor;
          if (filter.type == 'league' && filter.id != 'all') {
            // Use sport category color for league filters
            chipColor = AppTheme.getSportCategoryColor(filter.leagueIds.first);
          } else if (filter.type == 'include_leagues') {
            // Use primary color for multi-league filters
            chipColor = AppTheme.primaryColor;
          } else if (filter.type == 'exclude_league') {
            // Use accent color for exclusion filters
            chipColor = AppTheme.accentColor;
          } else if (isSelected) {
            // Use primary color for selected filters
            chipColor = AppTheme.primaryColor;
          } else {
            // Use text secondary color for non-selected filters
            chipColor = AppTheme.textSecondaryColor;
          }
          
          // Add exclusion indicator if needed
          Widget labelWidget = filter.isExclusion 
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.remove_circle_outline, size: 14),
                    const SizedBox(width: 4),
                    Text('Exclude ${filter.name}', 
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                )
              : filter.type == 'include_leagues'
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_circle_outline, size: 14),
                      const SizedBox(width: 4),
                      Text(filter.name,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  )
                : Text(filter.name);
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: labelWidget,
              selected: isSelected,
              onSelected: isDisabled ? null : (selected) {
                onFilterToggled(filter, selected);
              },
              backgroundColor: Colors.white,
              selectedColor: chipColor.withOpacity(0.1),
              labelStyle: TextStyle(
                color: isDisabled 
                    ? Colors.grey.shade400 
                    : (isSelected ? chipColor : AppTheme.textSecondaryColor),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              checkmarkColor: chipColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: BorderSide(
                  color: isDisabled 
                      ? Colors.grey.shade300 
                      : (isSelected ? chipColor : Colors.grey.shade300),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          );
        },
      ),
    );
  }

  // Static method to generate filter options from categories and events
  static List<FilterOption> generateFilterOptions(
    List<SportCategory> categories,
    List<SportEvent> events,
  ) {
    // Start with the "All Leagues" filter
    final List<FilterOption> filters = [
      FilterOption(id: 'all', name: 'All Leagues', type: 'all'),
    ];
    
    // Map to track categories with events
    final Map<String, SportCategory> categoriesWithEvents = {};
    
    // Find categories that have events
    for (final event in events) {
      final category = categories.firstWhere(
        (c) => c.id == event.sportCategoryId,
        orElse: () => SportCategory(
          id: event.sportCategoryId,
          name: 'Unknown League',
          description: '',
          iconData: 'sports',
        ),
      );
      categoriesWithEvents[category.id] = category;
    }
    
    // Add individual league filters
    for (final category in categoriesWithEvents.values) {
      // Regular inclusion filter
      filters.add(
        FilterOption(
          id: category.id,
          name: category.name,
          type: 'league',
          leagueIds: [category.id],
          isExclusion: false,
        ),
      );
      
      // Exclusion filter
      filters.add(
        FilterOption(
          id: 'exclude_${category.id}',
          name: category.name,
          type: 'exclude_league',
          leagueIds: [category.id],
          isExclusion: true,
        ),
      );
    }
    
    // Add some useful combined filters based on sport type
    
    // Basketball combined filters
    final basketballCategories = categoriesWithEvents.values
        .where((c) => c.id.contains('basketball'))
        .toList();
    
    if (basketballCategories.length > 1) {
      filters.add(
        FilterOption(
          id: 'basketball_all',
          name: 'All Basketball',
          type: 'include_leagues',
          leagueIds: basketballCategories.map((c) => c.id).toList(),
        ),
      );
    }
    
    // College basketball combined filter
    final collegeBasketballCategories = categoriesWithEvents.values
        .where((c) => c.id.contains('college') && c.id.contains('basketball'))
        .toList();
    
    if (collegeBasketballCategories.length > 1) {
      filters.add(
        FilterOption(
          id: 'college_basketball_all',
          name: 'All College Basketball',
          type: 'include_leagues',
          leagueIds: collegeBasketballCategories.map((c) => c.id).toList(),
        ),
      );
    }
    
    // Baseball combined filters
    final baseballCategories = categoriesWithEvents.values
        .where((c) => c.id.contains('baseball'))
        .toList();
    
    if (baseballCategories.length > 1) {
      filters.add(
        FilterOption(
          id: 'baseball_all',
          name: 'All Baseball',
          type: 'include_leagues',
          leagueIds: baseballCategories.map((c) => c.id).toList(),
        ),
      );
    }
    
    // Golf combined filter
    final golfCategories = categoriesWithEvents.values
        .where((c) => c.id.contains('golf') || c.id.contains('pga') || c.id.contains('wpga'))
        .toList();
    
    if (golfCategories.length > 1) {
      filters.add(
        FilterOption(
          id: 'golf_all',
          name: 'All Golf',
          type: 'include_leagues',
          leagueIds: golfCategories.map((c) => c.id).toList(),
        ),
      );
    }
    
    return filters;
  }
  
  // Filter events based on multiple selected filters
  static List<SportEvent> filterEvents(List<SportEvent> events, List<FilterOption> selectedFilters) {
    // If no filters are selected or 'all' is one of the selected filters, return all events
    if (selectedFilters.isEmpty || selectedFilters.any((filter) => filter.id == 'all')) {
      return events;
    }
    
    // Create sets for inclusion and exclusion
    final Set<String> includeLeagueIds = {};
    final Set<String> excludeLeagueIds = {};
    bool hasInclusionFilters = false;
    
    // Process all selected filters
    for (final filter in selectedFilters) {
      switch (filter.type) {
        case 'league':
          // Single league inclusion
          includeLeagueIds.addAll(filter.leagueIds);
          hasInclusionFilters = true;
          break;
          
        case 'include_leagues':
          // Multiple leagues inclusion
          includeLeagueIds.addAll(filter.leagueIds);
          hasInclusionFilters = true;
          break;
          
        case 'exclude_league':
          // League exclusion
          excludeLeagueIds.addAll(filter.leagueIds);
          break;
      }
    }
    
    // Apply both inclusion and exclusion filters
    return events.where((event) {
      // If inclusion filters are active, event must be in the inclusion set
      final shouldInclude = !hasInclusionFilters || includeLeagueIds.contains(event.sportCategoryId);
      
      // If exclusion filters are active, event must not be in the exclusion set
      final shouldExclude = excludeLeagueIds.contains(event.sportCategoryId);
      
      // Include only if it passes the include filter AND is not excluded
      return shouldInclude && !shouldExclude;
    }).toList();
  }
}