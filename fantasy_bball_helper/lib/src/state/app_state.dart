import "package:flutter/foundation.dart";
import "../services/nba_api_service.dart";
import "models.dart";

class AppState extends ChangeNotifier {
  AppState({NbaApiService? service})
      : _service = service ?? NbaApiService();

  final NbaApiService _service;

  bool _loading = true;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  DateTime _selectedWeekDate = DateTime.now();
  DateTime get selectedWeekDate => _selectedWeekDate;

  WeekFilter _weekFilter = WeekFilter.all;
  WeekFilter get weekFilter => _weekFilter;

  NbaApiService get service => _service;

  List<NbaGame> get gamesToday => _service.gamesToday();
  List<NbaGame> get gamesTomorrow => _service.gamesTomorrow();
  List<String> get backToBackTeams => _service.backToBackTeams();
  List<String> get teamsResting => _service.teamsResting();
  List<NbaTeam> get allTeams => _service.allTeams;

  Map<String, TeamWeekInfo> get weeklyBreakdown =>
      _service.gamesPerTeamWeek(_selectedWeekDate);

  List<TeamWeekInfo> get filteredWeeklyTeams {
    final breakdown = weeklyBreakdown;
    var teams = breakdown.values.toList();

    switch (_weekFilter) {
      case WeekFilter.fourPlus:
        teams = teams.where((t) => t.gamesThisWeek >= 4).toList();
        break;
      case WeekFilter.fivePlus:
        teams = teams.where((t) => t.gamesThisWeek >= 5).toList();
        break;
      case WeekFilter.all:
        break;
    }

    teams.sort((a, b) => b.gamesThisWeek.compareTo(a.gamesThisWeek));
    return teams;
  }

  Future<void> initialize() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.loadSchedule();
      _loading = false;
    } catch (e) {
      _error = "Failed to load NBA schedule. Check your connection.";
      _loading = false;
    }
    notifyListeners();
  }

  Future<void> refresh() async {
    _service.cachedSchedule = null;
    await initialize();
  }

  void setWeekFilter(WeekFilter filter) {
    _weekFilter = filter;
    notifyListeners();
  }

  void navigateWeek(int delta) {
    _selectedWeekDate = _selectedWeekDate.add(Duration(days: 7 * delta));
    notifyListeners();
  }

  void resetToCurrentWeek() {
    _selectedWeekDate = DateTime.now();
    notifyListeners();
  }

  List<NbaGame> teamScheduleThisWeek(String abbreviation) =>
      _service.teamScheduleThisWeek(abbreviation);

  int gamesLeftThisWeek(String abbreviation) =>
      _service.gamesLeftThisWeek(abbreviation);

  List<NbaGame> gamesDayOf(DateTime day) => _service.gamesDayOf(day);
}
