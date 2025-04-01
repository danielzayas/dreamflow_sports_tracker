import 'package:flutter/material.dart';
import '../models/sport_category.dart';
import '../models/sport_event.dart';
import 'local_storage_service.dart';
import 'espn_api_service.dart';

class DataService {
  final LocalStorageService _localStorageService = LocalStorageService();
  final EspnApiService _espnApiService = EspnApiService();
  
  // Initialize with sample data if no data exists
  Future<void> initializeData() async {
    final categories = await _localStorageService.loadSportCategories();
    final events = await _localStorageService.loadSportEvents();
    
    if (categories.isEmpty) {
      await _localStorageService.saveSportCategories(_getSampleSportCategories());
    }
    
    if (events.isEmpty) {
      try {
        // Try to fetch live data from ESPN APIs
        final List<SportEvent> espnEvents = await _fetchLiveEventsFromEspn();
        if (espnEvents.isNotEmpty) {
          await _localStorageService.saveSportEvents(espnEvents);
        } else {
          // Fall back to sample data if no events were fetched
          await _localStorageService.saveSportEvents(_getSampleSportEvents());
        }
      } catch (e) {
        print('Error fetching ESPN data: $e');
        // Fall back to sample data if there was an error
        await _localStorageService.saveSportEvents(_getSampleSportEvents());
      }
    }
  }
  
  // Refresh data from ESPN APIs
  Future<List<SportEvent>> refreshEventsFromEspn() async {
    try {
      final List<SportEvent> espnEvents = await _fetchLiveEventsFromEspn();
      if (espnEvents.isNotEmpty) {
        await _localStorageService.saveSportEvents(espnEvents);
        return espnEvents;
      }
    } catch (e) {
      print('Error refreshing ESPN data: $e');
      rethrow;
    }
    return await _localStorageService.loadSportEvents();
  }
  
  // Fetch live events from ESPN APIs
  Future<List<SportEvent>> _fetchLiveEventsFromEspn() async {
    List<SportEvent> allEvents = [];
    
    try {
      // Fetch MLB baseball scores
      final mlbData = await _espnApiService.getMlbScores();
      final mlbEvents = _espnApiService.convertEspnDataToEvents(mlbData, 'mlb');
      allEvents.addAll(mlbEvents);
      
      // Fetch NHL hockey scores
      final hockeyData = await _espnApiService.getHockeyScores();
      final hockeyEvents = _espnApiService.convertEspnDataToEvents(hockeyData, 'nhl');
      allEvents.addAll(hockeyEvents);
      
      // Fetch NBA basketball scores
      final nbaData = await _espnApiService.getNbaScores();
      final nbaEvents = _espnApiService.convertEspnDataToEvents(nbaData, 'nba');
      allEvents.addAll(nbaEvents);
      
      // Fetch WNBA scores
      final wnbaData = await _espnApiService.getWnbaScores();
      final wnbaEvents = _espnApiService.convertEspnDataToEvents(wnbaData, 'wnba');
      allEvents.addAll(wnbaEvents);
      
      // Fetch women's college basketball scores
      final womensBasketballData = await _espnApiService.getWomensBasketballScores();
      final womensBasketballEvents = _espnApiService.convertEspnDataToEvents(
        womensBasketballData, 'womens_ncaa_basketball');
      allEvents.addAll(womensBasketballEvents);
      
      // Fetch men's college basketball scores
      final mensBasketballData = await _espnApiService.getMensBasketballScores();
      final mensBasketballEvents = _espnApiService.convertEspnDataToEvents(
        mensBasketballData, 'mens_ncaa_basketball');
      allEvents.addAll(mensBasketballEvents);
      
      // Fetch college baseball scores
      final collegeBaseballData = await _espnApiService.getCollegeBaseballScores();
      final collegeBaseballEvents = _espnApiService.convertEspnDataToEvents(
        collegeBaseballData, 'college_baseball');
      allEvents.addAll(collegeBaseballEvents);
      
      // Add sample golf events since ESPN doesn't provide golf API endpoints
      allEvents.addAll(_getSampleGolfEvents());
      
      print('Fetched ${allEvents.length} events from ESPN');
    } catch (e) {
      print('Error fetching ESPN data: $e');
      // If ESPN API fails, return empty list and let the caller handle it
      rethrow;
    }
    
    return allEvents;
  }
  
  // Get sample golf events only
  List<SportEvent> _getSampleGolfEvents() {
    final now = DateTime.now();
    return [
      // PGA Golf Live Event
      SportEvent(
        id: 'pga_live_1',
        title: 'PGA Championship',
        sportCategoryId: 'pga_tour',
        startDateTime: now.subtract(const Duration(hours: 5)),
        endDateTime: now.add(const Duration(hours: 3)),
        location: 'Louisville, KY',
        description: 'PGA Championship final round',
        participants: [
          Participant(
            id: 'scheffler',
            name: 'Scottie Scheffler',
            imageUrl: 'https://pga-tour-res.cloudinary.com/image/upload/c_fill,dpr_2.0,f_auto,g_face:center,h_768,q_auto,w_768/v1/pgatour/editorial/2023/05/14/ScottieScheffler-Headshot-1694-Getty.jpg',
            isTeam: false,
          ),
          Participant(
            id: 'mcilroy',
            name: 'Rory McIlroy',
            imageUrl: 'https://pga-tour-res.cloudinary.com/image/upload/c_fill,dpr_2.0,f_auto,g_face:center,h_768,q_auto,w_768/v1/pgatour/editorial/2023/06/16/McIlroy-USOpen23-1694-JaredCTilton.jpg',
            isTeam: false,
          ),
          Participant(
            id: 'koepka',
            name: 'Brooks Koepka',
            imageUrl: 'https://pga-tour-res.cloudinary.com/image/upload/c_fill,dpr_2.0,f_auto,g_face:center,h_768,q_auto,w_768/v1/pgatour/editorial/2023/05/19/BrooksKoepka-1694-Getty.jpg',
            isTeam: false,
          ),
          Participant(
            id: 'thomas',
            name: 'Justin Thomas',
            imageUrl: 'https://pga-tour-res.cloudinary.com/image/upload/c_fill,dpr_2.0,f_auto,g_face:center,h_768,q_auto,w_768/v1/pgatour/editorial/2023/08/09/JustinThomas-1694-PGAChamp-Getty.jpg',
            isTeam: false,
          ),
        ],
        status: 'live',
        broadcast: 'CBS',
        score: Score(scoreData: {
          'scheffler': {'relativeToPar': -12, 'thru': 14},
          'mcilroy': {'relativeToPar': -10, 'thru': 16},
          'koepka': {'relativeToPar': -8, 'thru': 15},
          'thomas': {'relativeToPar': -7, 'thru': 17},
        }),
        timeElapsedInSeconds: 18000, // 5 hours elapsed
      ),
      
      // LPGA Golf Upcoming Event
      SportEvent(
        id: 'lpga_upcoming_1',
        title: "U.S. Women's Open",
        sportCategoryId: 'wpga_tour',
        startDateTime: now.add(const Duration(days: 4)),
        endDateTime: now.add(const Duration(days: 8)),
        location: 'Lancaster, PA',
        description: "U.S. Women's Open Championship",
        participants: [
          Participant(
            id: 'korda',
            name: 'Nelly Korda',
            imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9e/Nelly_Korda_%2852259831360%29.jpg/800px-Nelly_Korda_%2852259831360%29.jpg',
            isTeam: false,
          ),
          Participant(
            id: 'jin_young_ko',
            name: 'Jin Young Ko',
            imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c8/Jin_Young_Ko_%2852259831715%29.jpg/800px-Jin_Young_Ko_%2852259831715%29.jpg',
            isTeam: false,
          ),
          Participant(
            id: 'lydia_ko',
            name: 'Lydia Ko',
            imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/3/39/Lydia_Ko_by_Wojciech_Migda_-_Founders_Cup_2019-5050.jpg',
            isTeam: false,
          ),
        ],
        status: 'upcoming',
        broadcast: 'NBC, Golf Channel',
      ),
      
      // PGA Golf Upcoming Event
      SportEvent(
        id: 'pga_upcoming_1',
        title: 'U.S. Open',
        sportCategoryId: 'pga_tour',
        startDateTime: now.add(const Duration(days: 5)),
        endDateTime: now.add(const Duration(days: 9)),
        location: 'Pinehurst, NC',
        description: 'U.S. Open Championship',
        participants: [
          Participant(
            id: 'scheffler',
            name: 'Scottie Scheffler',
            imageUrl: 'https://pga-tour-res.cloudinary.com/image/upload/c_fill,dpr_2.0,f_auto,g_face:center,h_768,q_auto,w_768/v1/pgatour/editorial/2023/05/14/ScottieScheffler-Headshot-1694-Getty.jpg',
            isTeam: false,
          ),
          Participant(
            id: 'mcilroy',
            name: 'Rory McIlroy',
            imageUrl: 'https://pga-tour-res.cloudinary.com/image/upload/c_fill,dpr_2.0,f_auto,g_face:center,h_768,q_auto,w_768/v1/pgatour/editorial/2023/06/16/McIlroy-USOpen23-1694-JaredCTilton.jpg',
            isTeam: false,
          ),
          Participant(
            id: 'koepka',
            name: 'Brooks Koepka',
            imageUrl: 'https://pga-tour-res.cloudinary.com/image/upload/c_fill,dpr_2.0,f_auto,g_face:center,h_768,q_auto,w_768/v1/pgatour/editorial/2023/05/19/BrooksKoepka-1694-Getty.jpg',
            isTeam: false,
          ),
          Participant(
            id: 'thomas',
            name: 'Justin Thomas',
            imageUrl: 'https://pga-tour-res.cloudinary.com/image/upload/c_fill,dpr_2.0,f_auto,g_face:center,h_768,q_auto,w_768/v1/pgatour/editorial/2023/08/09/JustinThomas-1694-PGAChamp-Getty.jpg',
            isTeam: false,
          ),
        ],
        status: 'upcoming',
        broadcast: 'NBC, Peacock',
      ),
    ];
  }
  
  // Get all sport categories
  Future<List<SportCategory>> getSportCategories() async {
    return await _localStorageService.loadSportCategories();
  }
  
  // Get a specific sport category by ID
  Future<SportCategory?> getSportCategoryById(String id) async {
    final categories = await _localStorageService.loadSportCategories();
    return categories.firstWhere((category) => category.id == id, orElse: () => throw Exception('Category not found'));
  }
  
  // Get all sport events
  Future<List<SportEvent>> getSportEvents() async {
    return await _localStorageService.loadSportEvents();
  }
  
  // Get live events sorted by time remaining (ascending) or time elapsed (descending)
  Future<List<SportEvent>> getLiveEvents() async {
    final events = await _localStorageService.loadSportEvents();
    final liveEvents = events.where((event) => event.status == 'live').toList();
    
    liveEvents.sort((a, b) {
      // If both have time remaining, sort by time remaining (ascending)
      if (a.timeRemainingInSeconds != null && b.timeRemainingInSeconds != null) {
        return a.timeRemainingInSeconds!.compareTo(b.timeRemainingInSeconds!);
      }
      // If only a has time remaining, a comes first
      else if (a.timeRemainingInSeconds != null) {
        return -1;
      }
      // If only b has time remaining, b comes first
      else if (b.timeRemainingInSeconds != null) {
        return 1;
      }
      // If both have time elapsed, sort by time elapsed (descending)
      else if (a.timeElapsedInSeconds != null && b.timeElapsedInSeconds != null) {
        return b.timeElapsedInSeconds!.compareTo(a.timeElapsedInSeconds!);
      }
      // Otherwise sort by start time
      else {
        return a.startDateTime.compareTo(b.startDateTime);
      }
    });
    
    return liveEvents;
  }
  
  // Get upcoming events for the next 7 days sorted by start time (ascending)
  Future<List<SportEvent>> getUpcomingEvents() async {
    final events = await _localStorageService.loadSportEvents();
    final now = DateTime.now();
    final sevenDaysLater = now.add(const Duration(days: 7));
    
    final upcomingEvents = events.where((event) {
      return event.status == 'upcoming' && 
             event.startDateTime.isAfter(now) && 
             event.startDateTime.isBefore(sevenDaysLater);
    }).toList();
    
    upcomingEvents.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
    
    return upcomingEvents;
  }
  
  // Get events for a specific sport category
  Future<List<SportEvent>> getEventsBySportCategory(String categoryId) async {
    final events = await _localStorageService.loadSportEvents();
    return events.where((event) => event.sportCategoryId == categoryId).toList();
  }
  
  // Get events by status (upcoming, live, completed)
  Future<List<SportEvent>> getEventsByStatus(String status) async {
    final events = await _localStorageService.loadSportEvents();
    return events.where((event) => event.status == status).toList();
  }
  
  // Get a specific event by ID
  Future<SportEvent?> getEventById(String id) async {
    final events = await _localStorageService.loadSportEvents();
    return events.firstWhere((event) => event.id == id, orElse: () => throw Exception('Event not found'));
  }
  
  // Sample data for sport categories
  List<SportCategory> _getSampleSportCategories() {
    return [
      SportCategory(
        id: 'nba',
        name: "NBA Basketball",
        description: "National Basketball Association",
        iconData: 'sports_basketball',
      ),
      SportCategory(
        id: 'mens_ncaa_basketball',
        name: "Men's College Basketball",
        description: "NCAA events",
        iconData: 'sports_basketball',
      ),
      SportCategory(
        id: 'wnba',
        name: "WNBA Basketball",
        description: "Women's National Basketball Association",
        iconData: 'sports_basketball',
      ),
      SportCategory(
        id: 'womens_ncaa_basketball',
        name: "Women's College Basketball",
        description: "NCAA events",
        iconData: 'sports_basketball',
      ),
      SportCategory(
        id: 'mlb',
        name: "MLB Baseball",
        description: "Major League Baseball",
        iconData: 'sports_baseball',
      ),
      SportCategory(
        id: 'college_baseball',
        name: "College Baseball",
        description: "NCAA Baseball",
        iconData: 'sports_baseball',
      ),
      SportCategory(
        id: 'pga_tour',
        name: "Men's Golf",
        description: "PGA Tour events",
        iconData: 'sports_golf',
      ),
      SportCategory(
        id: 'wpga_tour',
        name: "Women's Golf",
        description: "LPGA Tour events",
        iconData: 'sports_golf',
      ),
      SportCategory(
        id: 'nhl',
        name: "NHL Hockey",
        description: "National Hockey League events",
        iconData: 'sports_hockey',
      ),
    ];
  }
  
  // Sample data for sport events with updated model
  List<SportEvent> _getSampleSportEvents() {
    final now = DateTime.now();
    return [
      // NBA Basketball Live Event
      SportEvent(
        id: 'nba_live_1',
        title: 'NBA Playoffs',
        sportCategoryId: 'nba',
        startDateTime: now.subtract(const Duration(hours: 1)),
        endDateTime: now.add(const Duration(hours: 1)),
        location: 'Boston, MA',
        description: 'NBA Playoffs Conference Finals',
        participants: [
          Participant(
            id: 'celtics',
            name: 'Boston Celtics',
            imageUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/8/8f/Boston_Celtics.svg/800px-Boston_Celtics.svg.png',
            isTeam: true,
          ),
          Participant(
            id: 'pacers',
            name: 'Indiana Pacers',
            imageUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/1/1b/Indiana_Pacers.svg/800px-Indiana_Pacers.svg.png',
            isTeam: true,
          ),
        ],
        status: 'live',
        broadcast: 'TNT',
        score: Score(scoreData: {
          'celtics': 82,
          'pacers': 76
        }),
        timeRemainingInSeconds: 720, // 12 minutes remaining
      ),
      
      // NHL Hockey Live Event
      SportEvent(
        id: 'nhl_live_1',
        title: 'Stanley Cup Playoffs',
        sportCategoryId: 'nhl',
        startDateTime: now.subtract(const Duration(hours: 2, minutes: 15)),
        endDateTime: now.add(const Duration(minutes: 30)),
        location: 'Edmonton, AB',
        description: 'Stanley Cup Playoffs Conference Finals',
        participants: [
          Participant(
            id: 'oilers',
            name: 'Edmonton Oilers',
            imageUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/4/4d/Logo_Edmonton_Oilers.svg/800px-Logo_Edmonton_Oilers.svg.png',
            isTeam: true,
          ),
          Participant(
            id: 'stars',
            name: 'Dallas Stars',
            imageUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/c/ce/Dallas_Stars_logo_%282013%29.svg/800px-Dallas_Stars_logo_%282013%29.svg.png',
            isTeam: true,
          ),
        ],
        status: 'live',
        broadcast: 'ESPN',
        score: Score(scoreData: {
          'oilers': 3,
          'stars': 2
        }),
        timeRemainingInSeconds: 420, // 7 minutes remaining
      ),
      
      // MLB Baseball Live Event
      SportEvent(
        id: 'mlb_live_1',
        title: 'MLB Regular Season',
        sportCategoryId: 'mlb',
        startDateTime: now.subtract(const Duration(hours: 1, minutes: 30)),
        endDateTime: now.add(const Duration(hours: 1, minutes: 30)),
        location: 'New York, NY',
        description: 'MLB Regular Season Game',
        participants: [
          Participant(
            id: 'yankees',
            name: 'New York Yankees',
            imageUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/2/25/NewYorkYankees_PrimaryLogo.svg/800px-NewYorkYankees_PrimaryLogo.svg.png',
            isTeam: true,
          ),
          Participant(
            id: 'redsox',
            name: 'Boston Red Sox',
            imageUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/6/6d/RedSoxPrimary_HangingSocks.svg/800px-RedSoxPrimary_HangingSocks.svg.png',
            isTeam: true,
          ),
        ],
        status: 'live',
        broadcast: 'ESPN',
        score: Score(scoreData: {
          'yankees': 5,
          'redsox': 3
        }),
        timeElapsedInSeconds: 6300, // Bottom of the 7th inning
      ),
      
      // PGA Golf Live Event
      SportEvent(
        id: 'pga_live_1',
        title: 'PGA Championship',
        sportCategoryId: 'pga_tour',
        startDateTime: now.subtract(const Duration(hours: 5)),
        endDateTime: now.add(const Duration(hours: 3)),
        location: 'Louisville, KY',
        description: 'PGA Championship final round',
        participants: [
          Participant(
            id: 'scheffler',
            name: 'Scottie Scheffler',
            imageUrl: 'https://pga-tour-res.cloudinary.com/image/upload/c_fill,dpr_2.0,f_auto,g_face:center,h_768,q_auto,w_768/v1/pgatour/editorial/2023/05/14/ScottieScheffler-Headshot-1694-Getty.jpg',
            isTeam: false,
          ),
          Participant(
            id: 'mcilroy',
            name: 'Rory McIlroy',
            imageUrl: 'https://pga-tour-res.cloudinary.com/image/upload/c_fill,dpr_2.0,f_auto,g_face:center,h_768,q_auto,w_768/v1/pgatour/editorial/2023/06/16/McIlroy-USOpen23-1694-JaredCTilton.jpg',
            isTeam: false,
          ),
          Participant(
            id: 'koepka',
            name: 'Brooks Koepka',
            imageUrl: 'https://pga-tour-res.cloudinary.com/image/upload/c_fill,dpr_2.0,f_auto,g_face:center,h_768,q_auto,w_768/v1/pgatour/editorial/2023/05/19/BrooksKoepka-1694-Getty.jpg',
            isTeam: false,
          ),
          Participant(
            id: 'thomas',
            name: 'Justin Thomas',
            imageUrl: 'https://pga-tour-res.cloudinary.com/image/upload/c_fill,dpr_2.0,f_auto,g_face:center,h_768,q_auto,w_768/v1/pgatour/editorial/2023/08/09/JustinThomas-1694-PGAChamp-Getty.jpg',
            isTeam: false,
          ),
        ],
        status: 'live',
        broadcast: 'CBS',
        score: Score(scoreData: {
          'scheffler': {'relativeToPar': -12, 'thru': 14},
          'mcilroy': {'relativeToPar': -10, 'thru': 16},
          'koepka': {'relativeToPar': -8, 'thru': 15},
          'thomas': {'relativeToPar': -7, 'thru': 17},
        }),
        timeElapsedInSeconds: 18000, // 5 hours elapsed
      ),
      
      // NBA Basketball Upcoming Event
      SportEvent(
        id: 'nba_upcoming_1',
        title: 'NBA Finals',
        sportCategoryId: 'nba',
        startDateTime: now.add(const Duration(days: 6)),
        endDateTime: now.add(const Duration(days: 20)),
        location: 'TBD',
        description: 'NBA Finals Championship Series',
        participants: [
          Participant(
            id: 'celtics',
            name: 'Boston Celtics',
            imageUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/8/8f/Boston_Celtics.svg/800px-Boston_Celtics.svg.png',
            isTeam: true,
          ),
          Participant(
            id: 'mavs',
            name: 'Dallas Mavericks',
            imageUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/9/97/Dallas_Mavericks_logo.svg/800px-Dallas_Mavericks_logo.svg.png',
            isTeam: true,
          ),
        ],
        status: 'upcoming',
        broadcast: 'ABC, ESPN',
      ),
      
      // WNBA Upcoming Event
      SportEvent(
        id: 'wnba_upcoming_1',
        title: 'WNBA Regular Season',
        sportCategoryId: 'wnba',
        startDateTime: now.add(const Duration(days: 2)),
        endDateTime: now.add(const Duration(days: 2, hours: 3)),
        location: 'New York, NY',
        description: 'WNBA Regular Season Game',
        participants: [
          Participant(
            id: 'liberty',
            name: 'New York Liberty',
            imageUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/7/76/New_York_Liberty_logo.svg/800px-New_York_Liberty_logo.svg.png',
            isTeam: true,
          ),
          Participant(
            id: 'aces',
            name: 'Las Vegas Aces',
            imageUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/f/fb/Las_Vegas_Aces_logo.svg/800px-Las_Vegas_Aces_logo.svg.png',
            isTeam: true,
          ),
        ],
        status: 'upcoming',
        broadcast: 'ESPN2',
      ),
      
      // MLB Baseball Upcoming Event
      SportEvent(
        id: 'mlb_upcoming_1',
        title: 'MLB Regular Season',
        sportCategoryId: 'mlb',
        startDateTime: now.add(const Duration(days: 1)),
        endDateTime: now.add(const Duration(days: 1, hours: 3)),
        location: 'Los Angeles, CA',
        description: 'MLB Regular Season Game',
        participants: [
          Participant(
            id: 'dodgers',
            name: 'Los Angeles Dodgers',
            imageUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/6/69/Los_Angeles_Dodgers_logo.svg/800px-Los_Angeles_Dodgers_logo.svg.png',
            isTeam: true,
          ),
          Participant(
            id: 'giants',
            name: 'San Francisco Giants',
            imageUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/5/58/San_Francisco_Giants_logo.svg/800px-San_Francisco_Giants_logo.svg.png',
            isTeam: true,
          ),
        ],
        status: 'upcoming',
        broadcast: 'FOX',
      ),
      
      // NHL Hockey Upcoming Event
      SportEvent(
        id: 'nhl_upcoming_1',
        title: 'Stanley Cup Finals',
        sportCategoryId: 'nhl',
        startDateTime: now.add(const Duration(days: 7)),
        endDateTime: now.add(const Duration(days: 21)),
        location: 'TBD',
        description: 'Stanley Cup Finals Championship Series',
        participants: [
          Participant(
            id: 'oilers',
            name: 'Edmonton Oilers',
            imageUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/4/4d/Logo_Edmonton_Oilers.svg/800px-Logo_Edmonton_Oilers.svg.png',
            isTeam: true,
          ),
          Participant(
            id: 'panthers',
            name: 'Florida Panthers',
            imageUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/4/43/Florida_Panthers_2016_logo.svg/800px-Florida_Panthers_2016_logo.svg.png',
            isTeam: true,
          ),
        ],
        status: 'upcoming',
        broadcast: 'ABC, ESPN',
      ),
    ];
  }
}