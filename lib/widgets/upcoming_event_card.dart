import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/theme.dart';
import '../models/sport_event.dart';
import '../widgets/shimmer_loading.dart';

class UpcomingEventCard extends StatelessWidget {
  final SportEvent event;
  final VoidCallback onTap;
  final bool isRefreshing;

  const UpcomingEventCard({
    Key? key,
    required this.event,
    required this.onTap,
    this.isRefreshing = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryColor = AppTheme.getSportCategoryColor(event.sportCategoryId);
    final dateFormat = DateFormat('E, MMM d'); // Tue, May 14
    final timeFormat = DateFormat('h:mm a'); // 3:30 PM
    final isTeamSport = event.isTeamSport;
    
    // ShimmerLoading wraps our content for refresh state
    return ShimmerLoading(
      isLoading: isRefreshing,
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.white.withOpacity(0.8),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Sport type and date/time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Sport type chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        event.title,
                        style: TextStyle(
                          color: categoryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    
                    // Date and time
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          dateFormat.format(event.startDateTime),
                          style: const TextStyle(
                            color: AppTheme.textPrimaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          timeFormat.format(event.startDateTime),
                          style: const TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Team/Player info
                if (isTeamSport)
                  _buildTeamSection(event, context)
                else
                  _buildPlayerSection(event, context),
                
                const SizedBox(height: 16),
                
                // Bottom row: Location and broadcast
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Location
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: AppTheme.textSecondaryColor),
                        const SizedBox(width: 4),
                        Text(
                          event.location,
                          style: const TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    
                    // Broadcast info
                    Row(
                      children: [
                        const Icon(Icons.tv, size: 14, color: AppTheme.textSecondaryColor),
                        const SizedBox(width: 4),
                        Text(
                          event.broadcast,
                          style: const TextStyle(
                            color: AppTheme.textSecondaryColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamSection(SportEvent event, BuildContext context) {
    final team1 = event.participants[0];
    final team2 = event.participants[1];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Team 1
        Expanded(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  team1.imageUrl,
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 50,
                    width: 50,
                    color: AppTheme.getSportCategoryColor(event.sportCategoryId).withOpacity(0.2),
                    child: const Icon(Icons.sports_basketball, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                team1.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        
        // VS
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'VS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ),
        
        // Team 2
        Expanded(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  team2.imageUrl,
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 50,
                    width: 50,
                    color: AppTheme.getSportCategoryColor(event.sportCategoryId).withOpacity(0.2),
                    child: const Icon(Icons.sports_basketball, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                team2.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerSection(SportEvent event, BuildContext context) {
    final player1 = event.participants[0];
    final player2 = event.participants[1];
    
    // For golf tournaments, show a different layout
    if (event.sportCategoryId.contains('golf')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Featured Players',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: event.participants.take(4).map((player) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        player.imageUrl,
                        height: 24,
                        width: 24,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 24,
                          width: 24,
                          color: AppTheme.getSportCategoryColor(event.sportCategoryId).withOpacity(0.2),
                          child: const Icon(Icons.sports_golf, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      player.name,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      );
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Player 1
        Expanded(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  player1.imageUrl,
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 50,
                    width: 50,
                    color: AppTheme.getSportCategoryColor(event.sportCategoryId).withOpacity(0.2),
                    child: const Icon(Icons.sports_tennis, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                player1.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        
        // VS
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'VS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ),
        
        // Player 2
        Expanded(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  player2.imageUrl,
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 50,
                    width: 50,
                    color: AppTheme.getSportCategoryColor(event.sportCategoryId).withOpacity(0.2),
                    child: const Icon(Icons.sports_tennis, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                player2.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}