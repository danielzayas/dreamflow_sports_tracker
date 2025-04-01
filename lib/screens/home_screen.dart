import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/theme.dart';
import '../providers/sport_events_provider.dart';
import '../widgets/app_logo.dart';
import '../widgets/event_filter.dart';
import '../widgets/live_event_card.dart';
import '../widgets/upcoming_event_card.dart';
import 'event_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    
    // Initialize the events provider
    Future.microtask(() {
      Provider.of<SportEventsProvider>(context, listen: false).initialize();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Method to refresh data with subtle indication
  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });
    
    try {
      // Use the new method that fetches fresh data from ESPN APIs
      await Provider.of<SportEventsProvider>(context, listen: false).refreshData();
    } catch (e) {
      // Show an error message if refresh fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to refresh: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'RETRY',
            textColor: Colors.white,
            onPressed: _refreshData,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const AppLogo(height: 36),
        centerTitle: false,
        actions: [
          // Show either a refresh button or a progress indicator
          _isRefreshing
              ? Center(
                  child: Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(right: 16),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _refreshData,
                  tooltip: 'Refresh data',
                ),
        ],
      ),
      body: Consumer<SportEventsProvider>(builder: (context, eventsProvider, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: RefreshIndicator(
            onRefresh: _refreshData,
            color: AppTheme.primaryColor,
            child: CustomScrollView(
              slivers: [
                // Filter section
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.filter_alt,
                                  color: AppTheme.primaryColor,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Filter by League',
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            // Clear filters button
                            if (eventsProvider.selectedFilters.length > 1 || 
                                (eventsProvider.selectedFilters.length == 1 && 
                                 eventsProvider.selectedFilters.first.id != 'all'))
                              TextButton.icon(
                                onPressed: () => eventsProvider.clearFilters(),
                                icon: const Icon(Icons.clear_all, size: 16),
                                label: const Text('Clear Filters'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppTheme.textSecondaryColor,
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                          ],
                        ),
                      ),
                      EventFilter(
                        filterOptions: eventsProvider.filterOptions,
                        selectedFilters: eventsProvider.selectedFilters,
                        onFilterToggled: eventsProvider.toggleFilter,
                      ),
                      const Divider(height: 24, indent: 16, endIndent: 16),
                      
                      // Selected filters indicator
                      if (eventsProvider.selectedFilters.length > 1)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              const Text(
                                'Active filters:',
                                style: TextStyle(
                                  color: AppTheme.textSecondaryColor,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 4),
                              ...eventsProvider.selectedFilters.map((filter) {
                                // Different styles for different filter types
                                Widget filterWidget;
                                
                                if (filter.type == 'exclude_league') {
                                  // Exclusion filter
                                  filterWidget = Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: AppTheme.accentColor.withOpacity(0.3))
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.remove_circle_outline, 
                                          size: 10, 
                                          color: AppTheme.accentColor
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          filter.name,
                                          style: const TextStyle(
                                            color: AppTheme.accentColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else if (filter.type == 'include_leagues') {
                                  // Multi-league inclusion filter
                                  filterWidget = Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3))
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.add_circle_outline, 
                                          size: 10, 
                                          color: AppTheme.primaryColor
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          filter.name,
                                          style: const TextStyle(
                                            color: AppTheme.primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else if (filter.type == 'league') {
                                  // Single league filter
                                  final Color categoryColor = AppTheme.getSportCategoryColor(filter.leagueIds.first);
                                  filterWidget = Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: categoryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: categoryColor.withOpacity(0.3))
                                    ),
                                    child: Text(
                                      filter.name,
                                      style: TextStyle(
                                        color: categoryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  );
                                } else {
                                  // All or other filter types
                                  filterWidget = Text(
                                    filter.name,
                                    style: const TextStyle(
                                      color: AppTheme.textPrimaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  );
                                }
                                
                                return filterWidget;
                              }).expand((widget) => [widget, const SizedBox(width: 4)]).take(eventsProvider.selectedFilters.length * 2 - 1),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Live section header
                SliverToBoxAdapter(
                  child: _buildSectionHeader('Live Now', AppTheme.liveColor, eventsProvider.isRefreshingLive),
                ),
                
                // Live events list or loading indicator
                _buildLiveEventsList(eventsProvider),
                
                // Upcoming section header
                SliverToBoxAdapter(
                  child: _buildSectionHeader('Upcoming', AppTheme.upcomingColor, eventsProvider.isRefreshingUpcoming),
                ),
                
                // Upcoming events list or loading indicator
                _buildUpcomingEventsList(eventsProvider),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title, Color color, bool isRefreshing) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isRefreshing) ...[  // Add a small loading indicator when refreshing
                const SizedBox(width: 8),
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
              const Spacer(),
              if (title == 'Live Now')
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.liveColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppTheme.liveColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'LIVE',
                        style: TextStyle(
                          color: AppTheme.liveColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          if (title == 'Upcoming') 
            const Text(
              'Next 7 days',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLiveEventsList(SportEventsProvider eventsProvider) {
    // Only show loading indicator for initial load, not refresh
    if (eventsProvider.isLoadingLive) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    
    if (eventsProvider.liveError != null) {
      return SliverToBoxAdapter(
        child: _buildErrorWidget(
          eventsProvider.liveError!,
          _refreshData,
        ),
      );
    }
    
    final liveEvents = eventsProvider.liveEvents;
    
    if (liveEvents.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.sports, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No live events right now',
                  style: TextStyle(color: AppTheme.textSecondaryColor),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final event = liveEvents[index];
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Padding(
              key: ValueKey(event.id), // This helps the AnimatedSwitcher detect changes
              padding: const EdgeInsets.only(bottom: 8.0),
              child: LiveEventCard(
                event: event,
                onTap: () => _navigateToEventDetails(event),
                isRefreshing: eventsProvider.isRefreshingLive,
              ),
            ),
          );
        },
        childCount: liveEvents.length,
      ),
    );
  }

  Widget _buildUpcomingEventsList(SportEventsProvider eventsProvider) {
    // Only show loading indicator for initial load, not refresh
    if (eventsProvider.isLoadingUpcoming) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    
    if (eventsProvider.upcomingError != null) {
      return SliverToBoxAdapter(
        child: _buildErrorWidget(
          eventsProvider.upcomingError!,
          _refreshData,
        ),
      );
    }
    
    final upcomingEvents = eventsProvider.upcomingEvents;
    
    if (upcomingEvents.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.event_busy, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No upcoming events in the next 7 days',
                  style: TextStyle(color: AppTheme.textSecondaryColor),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final event = upcomingEvents[index];
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Padding(
              key: ValueKey(event.id), // This helps the AnimatedSwitcher detect changes
              padding: const EdgeInsets.only(bottom: 8.0),
              child: UpcomingEventCard(
                event: event,
                onTap: () => _navigateToEventDetails(event),
                isRefreshing: eventsProvider.isRefreshingUpcoming,
              ),
            ),
          );
        },
        childCount: upcomingEvents.length,
      ),
    );
  }

  Widget _buildErrorWidget(String errorMessage, VoidCallback onRetry) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
            const SizedBox(height: 16),
            Text(
              'Error: $errorMessage',
              style: const TextStyle(color: AppTheme.errorColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEventDetails(event) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EventDetailsScreen(
          event: event,
          categoryColor: AppTheme.getSportCategoryColor(event.sportCategoryId),
        ),
      ),
    );
  }
}