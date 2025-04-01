import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/theme.dart';
import '../models/sport_event.dart';
import '../widgets/app_logo.dart';

class EventDetailsScreen extends StatelessWidget {
  final SportEvent event;
  final Color categoryColor;

  const EventDetailsScreen({
    Key? key,
    required this.event,
    required this.categoryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    final isTeamSport = event.isTeamSport;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const AppLogo(height: 32, showText: false),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero header
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    categoryColor.withOpacity(0.2),
                    AppTheme.backgroundColor,
                  ],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event title and status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                      ),
                      _buildStatusChip(event.status),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Event participants
                  if (isTeamSport)
                    _buildTeamSection(event, context)
                  else
                    _buildPlayerSection(event, context),
                    
                  if (event.status == 'live' && event.getTimeInfo().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        event.getTimeInfo(),
                        style: TextStyle(
                          color: AppTheme.liveColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Event details section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Broadcast information
                  _buildDetailCard(
                    title: 'Watch On',
                    icon: Icons.tv,
                    child: Text(
                      event.broadcast,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Date and time section
                  _buildDetailCard(
                    title: 'Date & Time',
                    icon: Icons.calendar_today,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start: ${dateFormat.format(event.startDateTime)} at ${timeFormat.format(event.startDateTime)}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'End: ${dateFormat.format(event.endDateTime)} at ${timeFormat.format(event.endDateTime)}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Location
                  _buildDetailCard(
                    title: 'Location',
                    icon: Icons.location_on,
                    child: Text(
                      event.location,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Description section
                  _buildDetailCard(
                    title: 'About this Event',
                    icon: Icons.info_outline,
                    child: Text(
                      event.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamSection(SportEvent event, BuildContext context) {
    final team1 = event.participants[0];
    final team2 = event.participants[1];
    String scoreText = '';
    
    if (event.status == 'live' && event.score != null) {
      if (event.sportCategoryId.contains('hockey')) {
        scoreText = event.score!.formatHockeyScore(team1.id, team2.id);
      } else {
        scoreText = event.score!.formatBasketballScore(team1.id, team2.id);
      }
    }
    
    final scoreParts = scoreText.isNotEmpty ? scoreText.split('-') : ['-', '-'];
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
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 80,
                    width: 80,
                    color: categoryColor.withOpacity(0.2),
                    child: const Icon(Icons.sports_basketball, color: Colors.white, size: 40),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                team1.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        // Score
        if (event.status == 'live' && scoreText.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'SCORE',
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      score1,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: categoryColor,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '-',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                    ),
                    Text(
                      score2,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: categoryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        else
          const Text(
            'VS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: AppTheme.textSecondaryColor,
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
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 80,
                    width: 80,
                    color: categoryColor.withOpacity(0.2),
                    child: const Icon(Icons.sports_basketball, color: Colors.white, size: 40),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                team2.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerSection(SportEvent event, BuildContext context) {
    // For golf tournaments with multiple players
    if (event.sportCategoryId.contains('golf')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Leaderboard',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          ...event.participants.map((player) {
            final score = event.status == 'live' && event.score != null
                ? event.score!.formatGolfScore(player.id)
                : '';
                
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  // Player image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.network(
                      player.imageUrl,
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 50,
                        width: 50,
                        color: categoryColor.withOpacity(0.2),
                        child: const Icon(Icons.sports_golf, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Player name and score
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          player.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        if (score.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: categoryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              score,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: categoryColor,
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
        ],
      );
    }
    
    // For 1v1 sports (like golf when showing just two players)
    final player1 = event.participants[0];
    final player2 = event.participants[1];
    String scoreText = '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Player 1
        Expanded(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.network(
                  player1.imageUrl,
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 80,
                    width: 80,
                    color: categoryColor.withOpacity(0.2),
                    child: const Icon(Icons.sports_tennis, color: Colors.white, size: 40),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                player1.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        // Score or VS
        if (event.status == 'live' && scoreText.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'SETS',
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  scoreText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: categoryColor,
                  ),
                ),
              ],
            ),
          )
        else
          const Text(
            'VS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        
        // Player 2
        Expanded(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.network(
                  player2.imageUrl,
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 80,
                    width: 80,
                    color: categoryColor.withOpacity(0.2),
                    child: const Icon(Icons.sports_tennis, color: Colors.white, size: 40),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                player2.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: categoryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: categoryColor,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final color = AppTheme.getStatusColor(status);
    String label = status.substring(0, 1).toUpperCase() + status.substring(1);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == 'live')
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}