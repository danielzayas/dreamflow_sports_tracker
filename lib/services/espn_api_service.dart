import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sport_event.dart';

class EspnApiService {
  // Base URL for ESPN API
  final String baseUrl = 'http://site.api.espn.com/apis/site/v2/sports';
  
  // ======= BASEBALL ENDPOINTS =======
  
  // Fetch MLB baseball scores
  Future<Map<String, dynamic>> getMlbScores() async {
    final response = await http.get(Uri.parse('$baseUrl/baseball/mlb/scoreboard'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load MLB scores');
    }
  }
  
  // Fetch MLB news
  Future<Map<String, dynamic>> getMlbNews() async {
    final response = await http.get(Uri.parse('$baseUrl/baseball/mlb/news'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load MLB news');
    }
  }
  
  // Fetch MLB teams
  Future<Map<String, dynamic>> getMlbTeams() async {
    final response = await http.get(Uri.parse('$baseUrl/baseball/mlb/teams'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load MLB teams');
    }
  }
  
  // Fetch specific MLB team
  Future<Map<String, dynamic>> getMlbTeam(String teamId) async {
    final response = await http.get(Uri.parse('$baseUrl/baseball/mlb/teams/$teamId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load MLB team');
    }
  }
  
  // Fetch college baseball scores
  Future<Map<String, dynamic>> getCollegeBaseballScores() async {
    final response = await http.get(Uri.parse('$baseUrl/baseball/college-baseball/scoreboard'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load college baseball scores');
    }
  }
  
  // ======= HOCKEY ENDPOINTS =======
  
  // Fetch NHL hockey scores
  Future<Map<String, dynamic>> getHockeyScores() async {
    final response = await http.get(Uri.parse('$baseUrl/hockey/nhl/scoreboard'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load hockey scores');
    }
  }
  
  // Fetch hockey news
  Future<Map<String, dynamic>> getHockeyNews() async {
    final response = await http.get(Uri.parse('$baseUrl/hockey/nhl/news'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load hockey news');
    }
  }
  
  // Fetch hockey teams
  Future<Map<String, dynamic>> getHockeyTeams() async {
    final response = await http.get(Uri.parse('$baseUrl/hockey/nhl/teams'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load hockey teams');
    }
  }
  
  // Fetch specific hockey team
  Future<Map<String, dynamic>> getHockeyTeam(String teamId) async {
    final response = await http.get(Uri.parse('$baseUrl/hockey/nhl/teams/$teamId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load hockey team');
    }
  }
  
  // ======= BASKETBALL ENDPOINTS =======
  
  // Fetch NBA basketball scores
  Future<Map<String, dynamic>> getNbaScores() async {
    final response = await http.get(Uri.parse('$baseUrl/basketball/nba/scoreboard'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load NBA scores');
    }
  }
  
  // Fetch NBA news
  Future<Map<String, dynamic>> getNbaNews() async {
    final response = await http.get(Uri.parse('$baseUrl/basketball/nba/news'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load NBA news');
    }
  }
  
  // Fetch NBA teams
  Future<Map<String, dynamic>> getNbaTeams() async {
    final response = await http.get(Uri.parse('$baseUrl/basketball/nba/teams'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load NBA teams');
    }
  }
  
  // Fetch specific NBA team
  Future<Map<String, dynamic>> getNbaTeam(String teamId) async {
    final response = await http.get(Uri.parse('$baseUrl/basketball/nba/teams/$teamId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load NBA team');
    }
  }
  
  // Fetch WNBA scores
  Future<Map<String, dynamic>> getWnbaScores() async {
    final response = await http.get(Uri.parse('$baseUrl/basketball/wnba/scoreboard'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load WNBA scores');
    }
  }
  
  // Fetch women's college basketball scores
  Future<Map<String, dynamic>> getWomensBasketballScores() async {
    final response = await http.get(Uri.parse('$baseUrl/basketball/womens-college-basketball/scoreboard'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load women\'s basketball scores');
    }
  }
  
  // Fetch men's college basketball scores
  Future<Map<String, dynamic>> getMensBasketballScores() async {
    final response = await http.get(Uri.parse('$baseUrl/basketball/mens-college-basketball/scoreboard'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load men\'s basketball scores');
    }
  }
  
  // Convert ESPN data to SportEvent objects
  List<SportEvent> convertEspnDataToEvents(Map<String, dynamic> data, String sportCategoryId) {
    final List<SportEvent> events = [];
    final List<dynamic> eventsData = data['events'] ?? [];
    
    for (final eventData in eventsData) {
      try {
        final String id = eventData['id'] ?? '';
        final String title = eventData['name'] ?? 'Unknown Event';
        final String shortTitle = eventData['shortName'] ?? title;
        
        // Parse date and time
        final String dateTimeString = eventData['date'] ?? '';
        DateTime startDateTime;
        try {
          startDateTime = DateTime.parse(dateTimeString);
        } catch (e) {
          startDateTime = DateTime.now();
        }
        
        // Default end time is 3 hours after start time
        final DateTime endDateTime = startDateTime.add(const Duration(hours: 3));
        
        // Location
        final Map<String, dynamic>? venueData = eventData['competitions']?[0]?['venue'];
        final String location = venueData?['fullName'] ?? 
            '${venueData?['city'] ?? ''}, ${venueData?['state'] ?? ''}'.trim();
        
        // Description
        final String description = eventData['competitions']?[0]?['notes']?[0]?['headline'] ?? title;
        
        // Participants
        final List<Participant> participants = [];
        final List<dynamic> competitorsData = eventData['competitions']?[0]?['competitors'] ?? [];
        
        for (final competitorData in competitorsData) {
          final String competitorId = competitorData['id'] ?? '';
          final String competitorName = competitorData['team']?['displayName'] ?? competitorData['team']?['name'] ?? 'Unknown Team';
          final String competitorLogo = competitorData['team']?['logo'] ?? '';
          final String teamAbbrev = competitorData['team']?['abbreviation'] ?? '';
          
          participants.add(Participant(
            id: competitorId,
            name: competitorName,
            imageUrl: competitorLogo,
            isTeam: true,
          ));
        }
        
        // Status
        String status = 'upcoming';
        if (eventData['status']?['type']?['state'] == 'in') {
          status = 'live';
        } else if (eventData['status']?['type']?['state'] == 'post') {
          status = 'completed';
        }
        
        // Broadcast
        final List<dynamic> broadcastsList = eventData['competitions']?[0]?['broadcasts'] ?? [];
        String broadcast = 'Check local listings';
        if (broadcastsList.isNotEmpty) {
          final List<dynamic> namesList = broadcastsList[0]['names'] ?? [];
          if (namesList.isNotEmpty) {
            broadcast = namesList.join(', ');
          }
        }
        
        // Score
        Score? score;
        int? timeRemainingInSeconds;
        int? timeElapsedInSeconds;
        
        if (status == 'live' || status == 'completed') {
          final Map<String, dynamic> scoreData = {};
          
          for (final competitorData in competitorsData) {
            final String competitorId = competitorData['id'] ?? '';
            final int? competitorScore = int.tryParse(competitorData['score'] ?? '0');
            
            if (competitorId.isNotEmpty && competitorScore != null) {
              scoreData[competitorId] = competitorScore;
            }
          }
          
          if (scoreData.isNotEmpty) {
            score = Score(scoreData: scoreData);
          }
          
          // Time remaining/elapsed
          if (status == 'live') {
            final int period = eventData['status']?['period'] ?? 1;
            final String displayClock = eventData['status']?['displayClock'] ?? '0:00';
            final String statusDetail = eventData['status']?['type']?['shortDetail'] ?? '';
            
            if (displayClock != 'HALFTIME' && displayClock != 'FINAL') {
              // Convert "MM:SS" to seconds
              final List<String> parts = displayClock.split(':');
              if (parts.length == 2) {
                final int minutes = int.tryParse(parts[0]) ?? 0;
                final int seconds = int.tryParse(parts[1]) ?? 0;
                timeRemainingInSeconds = minutes * 60 + seconds;
              }
              
              // Calculate elapsed time based on sport type
              if (sportCategoryId.contains('nba')) {
                final int totalTimePerPeriod = 12 * 60; // 12 minutes per quarter in NBA
                timeElapsedInSeconds = (period - 1) * totalTimePerPeriod + 
                    (totalTimePerPeriod - (timeRemainingInSeconds ?? 0));
              } else if (sportCategoryId.contains('mens_basketball')) {
                final int totalTimePerPeriod = 20 * 60; // 20 minutes per half in NCAA men's
                timeElapsedInSeconds = (period - 1) * totalTimePerPeriod + 
                    (totalTimePerPeriod - (timeRemainingInSeconds ?? 0));
              } else if (sportCategoryId.contains('womens_basketball')) {
                final int totalTimePerPeriod = 10 * 60; // 10 minutes per quarter in NCAA women's
                timeElapsedInSeconds = (period - 1) * totalTimePerPeriod + 
                    (totalTimePerPeriod - (timeRemainingInSeconds ?? 0));
              } else if (sportCategoryId.contains('hockey')) {
                final int totalTimePerPeriod = 20 * 60; // 20 minutes per period in NHL
                timeElapsedInSeconds = (period - 1) * totalTimePerPeriod + 
                    (totalTimePerPeriod - (timeRemainingInSeconds ?? 0));
              } else if (sportCategoryId.contains('baseball')) {
                // For baseball, we don't have clear time remaining, so we just use inning
                timeElapsedInSeconds = period * 900; // Rough estimate, 15 minutes per inning
              }
            }
          }
        }
        
        events.add(SportEvent(
          id: id,
          title: title,
          sportCategoryId: sportCategoryId,
          startDateTime: startDateTime,
          endDateTime: endDateTime,
          location: location,
          description: description,
          participants: participants,
          status: status,
          broadcast: broadcast,
          score: score,
          timeRemainingInSeconds: timeRemainingInSeconds,
          timeElapsedInSeconds: timeElapsedInSeconds,
        ));
      } catch (e) {
        // Skip this event if there was an error
        print('Error converting event: $e');
      }
    }
    
    return events;
  }
}