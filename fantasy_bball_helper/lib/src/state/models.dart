import "package:flutter/foundation.dart";

@immutable
class NbaGame {
  const NbaGame({
    required this.gameCode,
    required this.date,
    required this.homeAbbrev,
    required this.awayAbbrev,
    required this.homeName,
    required this.awayName,
    this.homeScore,
    this.awayScore,
    this.statusText,
  });

  final String gameCode;
  final DateTime date;
  final String homeAbbrev;
  final String awayAbbrev;
  final String homeName;
  final String awayName;
  final int? homeScore;
  final int? awayScore;
  final String? statusText;

  String get displayLabel => "$awayName at $homeName";
}

@immutable
class TeamWeekInfo {
  const TeamWeekInfo({
    required this.teamName,
    required this.abbreviation,
    required this.gamesThisWeek,
    required this.gamesRemaining,
    required this.gameDates,
  });

  final String teamName;
  final String abbreviation;
  final int gamesThisWeek;
  final int gamesRemaining;
  final List<DateTime> gameDates;
}

@immutable
class NbaTeam {
  const NbaTeam({
    required this.id,
    required this.fullName,
    required this.abbreviation,
    required this.city,
    required this.nickname,
    required this.conference,
  });

  final int id;
  final String fullName;
  final String abbreviation;
  final String city;
  final String nickname;
  final String conference;
}

enum WeekFilter { all, fourPlus, fivePlus }
