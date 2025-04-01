class SportEvent {
  final String id;
  final String title;
  final String sportCategoryId;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String location;
  final String description;
  final List<Participant> participants;
  final String status; // 'upcoming', 'live', 'completed'
  final String broadcast; // Where to watch (e.g., "ESPN", "NBC Sports")
  final Score? score; // Score information for live or completed events
  final int? timeRemainingInSeconds; // For live events, time remaining in seconds
  final int? timeElapsedInSeconds; // For live events, time elapsed in seconds

  SportEvent({
    required this.id,
    required this.title,
    required this.sportCategoryId,
    required this.startDateTime,
    required this.endDateTime,
    required this.location,
    required this.description,
    required this.participants,
    required this.status,
    required this.broadcast,
    this.score,
    this.timeRemainingInSeconds,
    this.timeElapsedInSeconds,
  });

  // Helper method to determine if the event is a team sport
  bool get isTeamSport {
    return participants.isNotEmpty && participants.first.isTeam;
  }

  // Get a formatted string for time remaining or elapsed
  String getTimeInfo() {
    if (status == 'live') {
      if (timeRemainingInSeconds != null) {
        final minutes = (timeRemainingInSeconds! / 60).floor();
        final seconds = timeRemainingInSeconds! % 60;
        return '$minutes:${seconds.toString().padLeft(2, '0')} remaining';
      } else if (timeElapsedInSeconds != null) {
        final minutes = (timeElapsedInSeconds! / 60).floor();
        final seconds = timeElapsedInSeconds! % 60;
        return '$minutes:${seconds.toString().padLeft(2, '0')} elapsed';
      }
    }
    return '';
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'sportCategoryId': sportCategoryId,
      'startDateTime': startDateTime.toIso8601String(),
      'endDateTime': endDateTime.toIso8601String(),
      'location': location,
      'description': description,
      'participants': participants.map((p) => p.toJson()).toList(),
      'status': status,
      'broadcast': broadcast,
      'score': score?.toJson(),
      'timeRemainingInSeconds': timeRemainingInSeconds,
      'timeElapsedInSeconds': timeElapsedInSeconds,
    };
  }

  // Create from JSON
  factory SportEvent.fromJson(Map<String, dynamic> json) {
    return SportEvent(
      id: json['id'],
      title: json['title'],
      sportCategoryId: json['sportCategoryId'],
      startDateTime: DateTime.parse(json['startDateTime']),
      endDateTime: DateTime.parse(json['endDateTime']),
      location: json['location'],
      description: json['description'],
      participants: (json['participants'] as List)
          .map((p) => Participant.fromJson(p))
          .toList(),
      status: json['status'],
      broadcast: json['broadcast'] ?? 'Check local listings',
      score: json['score'] != null ? Score.fromJson(json['score']) : null,
      timeRemainingInSeconds: json['timeRemainingInSeconds'],
      timeElapsedInSeconds: json['timeElapsedInSeconds'],
    );
  }
}

class Participant {
  final String id;
  final String name;
  final String imageUrl;
  final bool isTeam;

  Participant({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.isTeam,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'isTeam': isTeam,
    };
  }

  // Create from JSON
  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      isTeam: json['isTeam'] ?? false,
    );
  }
}

class Score {
  final Map<String, dynamic> scoreData; // Flexible structure for different sports

  Score({required this.scoreData});

  // Helper method to get a participant's score
  dynamic getParticipantScore(String participantId) {
    return scoreData[participantId];
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return scoreData;
  }

  // Create from JSON
  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(scoreData: json);
  }

  // This method was removed because tennis is no longer supported
  
  // Format the score as a string (for basketball)
  String formatBasketballScore(String team1Id, String team2Id) {
    final team1Score = scoreData[team1Id];
    final team2Score = scoreData[team2Id];
    return '$team1Score-$team2Score';
  }
  
  // Format the score as a string (for hockey)
  String formatHockeyScore(String team1Id, String team2Id) {
    final team1Score = scoreData[team1Id];
    final team2Score = scoreData[team2Id];
    return '$team1Score-$team2Score';
  }
  
  // Format the score as a string (for golf)
  String formatGolfScore(String playerId) {
    final playerScore = scoreData[playerId];
    final relativeToPar = playerScore['relativeToPar'];
    return relativeToPar > 0 ? '+$relativeToPar' : '$relativeToPar';
  }
}