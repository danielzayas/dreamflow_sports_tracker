import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/theme.dart';
import '../models/sport_event.dart';
import '../widgets/shimmer_loading.dart';

class LiveEventCard extends StatelessWidget {
  final SportEvent event;
  final VoidCallback onTap;
  final bool isRefreshing;

  const LiveEventCard({
    Key? key,
    required this.event,
    required this.onTap,
    this.isRefreshing = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryColor = AppTheme.getSportCategoryColor(event.sportCategoryId);
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
                // Top row: Sport type and live indicator
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
                    
                    // Live indicator
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
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
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Team/Player info and score
                if (isTeamSport)
                  _buildTeamScoreSection(event, context)
                else
                  _buildPlayerScoreSection(event, context),
                
                const SizedBox(height: 16),
                
                // Bottom row: Time info and broadcast
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Time remaining/elapsed
                    Text(
                      event.getTimeInfo(),
                      style: TextStyle(
                        color: AppTheme.liveColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
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

  Widget _buildTeamScoreSection(SportEvent event, BuildContext context) {
    final team1 = event.participants[0];
    final team2 = event.participants[1];
    String scoreText = event.score != null ? 
        event.score!.formatBasketballScore(team1.id, team2.id) : '-';
        
    if (event.sportCategoryId.contains('hockey')) {
      scoreText = event.score != null ? 
        event.score!.formatHockeyScore(team1.id, team2.id) : '-';
    }
    
    final scoreParts = scoreText.split('-');
    final score1 = scoreParts[0];
    final score2 = scoreParts.length > 1 ? scoreParts[1] : '-';

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
        
        // Score
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                score1,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '-',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              Text(
                score2,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
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

  Widget _buildPlayerScoreSection(SportEvent event, BuildContext context) {
    final player1 = event.participants[0];
    final player2 = event.participants[1];
    String scoreText = '';
    
    if (event.sportCategoryId.contains('golf')) {
      // For golf, we display individual scores differently
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: event.participants.map((player) {
          final score = event.score != null ? 
            event.score!.formatGolfScore(player.id) : '-';
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                // Player image
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    player.imageUrl,
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 40,
                      width: 40,
                      color: AppTheme.getSportCategoryColor(event.sportCategoryId).withOpacity(0.2),
                      child: const Icon(Icons.sports_golf, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Player name and score
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        player.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.getSportCategoryColor(event.sportCategoryId).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          score,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.getSportCategoryColor(event.sportCategoryId),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
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
        
        // VS with score
        Column(
          children: [
            const Text(
              'VS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            if (scoreText.isNotEmpty) 
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  scoreText,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
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