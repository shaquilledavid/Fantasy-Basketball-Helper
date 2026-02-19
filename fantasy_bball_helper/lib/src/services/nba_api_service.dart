import "dart:convert";
import "package:flutter/foundation.dart";
import "package:http/http.dart" as http;
import "../state/models.dart";

class NbaApiService {
  static const String _scheduleUrl =
      "https://data.nba.com/data/10s/v2015/json/mobile_teams/nba/2025/league/00_full_schedule.json";

  Map<String, dynamic>? cachedSchedule;

  static const Map<String, String> teamsAbbrev = {
    "ATL": "Atlanta Hawks",
    "BOS": "Boston Celtics",
    "BKN": "Brooklyn Nets",
    "CHA": "Charlotte Hornets",
    "CHI": "Chicago Bulls",
    "CLE": "Cleveland Cavaliers",
    "DAL": "Dallas Mavericks",
    "DEN": "Denver Nuggets",
    "DET": "Detroit Pistons",
    "GSW": "Golden State Warriors",
    "HOU": "Houston Rockets",
    "IND": "Indiana Pacers",
    "LAC": "LA Clippers",
    "LAL": "Los Angeles Lakers",
    "MEM": "Memphis Grizzlies",
    "MIA": "Miami Heat",
    "MIL": "Milwaukee Bucks",
    "MIN": "Minnesota Timberwolves",
    "NOP": "New Orleans Pelicans",
    "NYK": "New York Knicks",
    "OKC": "Oklahoma City Thunder",
    "ORL": "Orlando Magic",
    "PHI": "Philadelphia 76ers",
    "PHX": "Phoenix Suns",
    "POR": "Portland Trail Blazers",
    "SAC": "Sacramento Kings",
    "SAS": "San Antonio Spurs",
    "TOR": "Toronto Raptors",
    "UTA": "Utah Jazz",
    "WAS": "Washington Wizards",
  };

  static const Map<String, String> teamConferences = {
    "ATL": "East", "BOS": "East", "BKN": "East", "CHA": "East", "CHI": "East",
    "CLE": "East", "DET": "East", "IND": "East", "MIA": "East", "MIL": "East",
    "NYK": "East", "ORL": "East", "PHI": "East", "TOR": "East", "WAS": "East",
    "DAL": "West", "DEN": "West", "GSW": "West", "HOU": "West", "LAC": "West",
    "LAL": "West", "MEM": "West", "MIN": "West", "NOP": "West", "OKC": "West",
    "PHX": "West", "POR": "West", "SAC": "West", "SAS": "West", "UTA": "West",
  };

  static const Map<int, String> _months = {
    1: "January", 2: "February", 3: "March", 4: "April",
    5: "May", 6: "June", 7: "July", 8: "August",
    9: "September", 10: "October", 11: "November", 12: "December",
  };

  List<NbaTeam> get allTeams => teamsAbbrev.entries.map((e) {
        final parts = e.value.split(" ");
        final city = parts.length > 2
            ? parts.sublist(0, parts.length - 1).join(" ")
            : parts.first;
        final nickname = parts.last;
        return NbaTeam(
          id: e.key.hashCode,
          fullName: e.value,
          abbreviation: e.key,
          city: city,
          nickname: nickname,
          conference: teamConferences[e.key] ?? "Unknown",
        );
      }).toList()
        ..sort((a, b) => a.fullName.compareTo(b.fullName));

  Future<void> loadSchedule() async {
    if (cachedSchedule != null) return;
    try {
      final response = await http.get(Uri.parse(_scheduleUrl));
      if (response.statusCode == 200) {
        cachedSchedule = json.decode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint("Failed to load schedule: $e");
    }
  }

  List<String> get _seasonMonths {
    if (cachedSchedule == null) return [];
    final lscd = cachedSchedule!["lscd"] as List<dynamic>;
    return lscd
        .map((m) => (m["mscd"]["mon"] as String))
        .toList();
  }

  List<NbaGame> gamesDayOf(DateTime day) {
    if (cachedSchedule == null) return [];

    final monthName = _months[day.month];
    if (monthName == null || !_seasonMonths.contains(monthName)) return [];

    final index = _seasonMonths.indexOf(monthName);
    final lscd = cachedSchedule!["lscd"] as List<dynamic>;
    final monthGames = lscd[index]["mscd"]["g"] as List<dynamic>;
    final dayIso = _isoDate(day);

    final games = <NbaGame>[];
    for (final g in monthGames) {
      if (g["gdte"] == dayIso) {
        final code = g["gcode"] as String;
        final homeAbbrev = code.substring(9, 12);
        final awayAbbrev = code.substring(12);
        games.add(NbaGame(
          gameCode: code,
          date: day,
          homeAbbrev: homeAbbrev,
          awayAbbrev: awayAbbrev,
          homeName: teamsAbbrev[homeAbbrev] ?? homeAbbrev,
          awayName: teamsAbbrev[awayAbbrev] ?? awayAbbrev,
          statusText: g["stt"] as String?,
        ));
      }
    }
    return games;
  }

  List<NbaGame> gamesToday() => gamesDayOf(DateTime.now());

  List<NbaGame> gamesTomorrow() =>
      gamesDayOf(DateTime.now().add(const Duration(days: 1)));

  List<String> teamsThatPlayOn(DateTime day) {
    final games = gamesDayOf(day);
    final teams = <String>[];
    for (final g in games) {
      teams.add(g.homeName);
      teams.add(g.awayName);
    }
    return teams;
  }

  List<String> backToBackTeams() {
    final todayTeams = teamsThatPlayOn(DateTime.now());
    final tomorrowTeams =
        teamsThatPlayOn(DateTime.now().add(const Duration(days: 1)));
    return todayTeams.where((t) => tomorrowTeams.contains(t)).toList();
  }

  List<String> backToBackOn(DateTime day) {
    final dayTeams = teamsThatPlayOn(day);
    final nextTeams = teamsThatPlayOn(day.add(const Duration(days: 1)));
    return dayTeams.where((t) => nextTeams.contains(t)).toList();
  }

  List<String> teamsResting() {
    final todayTeams = teamsThatPlayOn(DateTime.now()).toSet();
    final tomorrowTeams =
        teamsThatPlayOn(DateTime.now().add(const Duration(days: 1))).toSet();
    return teamsAbbrev.values
        .where((t) => !todayTeams.contains(t) && !tomorrowTeams.contains(t))
        .toList();
  }

  /// Returns Mon-Sun week containing [day].
  List<DateTime> _weekDates(DateTime day) {
    final weekday = day.weekday; // 1=Monday
    final monday = day.subtract(Duration(days: weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  Map<String, TeamWeekInfo> gamesPerTeamWeek(DateTime anyDayInWeek) {
    final week = _weekDates(anyDayInWeek);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final result = <String, TeamWeekInfo>{};

    for (final abbrev in teamsAbbrev.keys) {
      final fullName = teamsAbbrev[abbrev]!;
      final gameDates = <DateTime>[];

      for (final day in week) {
        final teams = teamsThatPlayOn(day);
        if (teams.contains(fullName)) {
          gameDates.add(day);
        }
      }

      final remaining =
          gameDates.where((d) => !d.isBefore(today)).length;

      result[abbrev] = TeamWeekInfo(
        teamName: fullName,
        abbreviation: abbrev,
        gamesThisWeek: gameDates.length,
        gamesRemaining: remaining,
        gameDates: gameDates,
      );
    }
    return result;
  }

  List<TeamWeekInfo> teamsWithNGames(DateTime anyDayInWeek, int n) {
    final breakdown = gamesPerTeamWeek(anyDayInWeek);
    return breakdown.values
        .where((t) => t.gamesThisWeek >= n)
        .toList()
      ..sort((a, b) => b.gamesThisWeek.compareTo(a.gamesThisWeek));
  }

  List<NbaGame> teamScheduleThisWeek(String abbreviation) {
    final week = _weekDates(DateTime.now());
    final games = <NbaGame>[];

    for (final day in week) {
      for (final g in gamesDayOf(day)) {
        if (g.homeAbbrev == abbreviation || g.awayAbbrev == abbreviation) {
          games.add(g);
        }
      }
    }
    return games;
  }

  int gamesLeftThisWeek(String abbreviation) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return teamScheduleThisWeek(abbreviation)
        .where((g) => !g.date.isBefore(today))
        .length;
  }

  String _isoDate(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
}
