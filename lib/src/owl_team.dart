import 'dart:ui';

import 'win_loss_record.dart';

class OwlTeam {
  final String name;
  final Color primaryColor;
  final OwlSeason? season1;
  final OwlSeason season2;
  final OwlSeason season3;

  const OwlTeam({
    required this.name,
    required this.season1,
    required this.season2,
    required this.season3,
    required this.primaryColor,
  });

  factory OwlTeam.fromJson(Map<String, dynamic> json) {
    final teamName = json['team_name'];
    final season1 = json['season_1'];
    final season2 = json['season_2'];
    final season3 = json['season_3'];

    final <String, dynamic>{'r': int r, 'g': int g, 'b': int b} =
        season2['primary_color'];
    final primaryColor = Color.fromRGBO(r, g, b, 1);

    return OwlTeam(
      name: teamName,
      primaryColor: primaryColor,
      season1: switch (season1) {
        Map<String, dynamic> season1 => OwlSeason.fromJson('Season 1', season1),
        _ => null,
      },
      season2: OwlSeason.fromJson('Season 2', season2),
      season3: OwlSeason.season3(season3),
    );
  }

  Iterable<OwlWeek> get weeks sync* {
    yield* season1?.weeks ?? const Iterable.empty();
    yield* season2.weeks;
    yield* season3.weeks;
  }

  List<MatchDifferential> buildMatchDifferentialForWeeks() {
    var fold = weeks.fold(
      [MatchDifferential.zero],
      (diff, week) => [...diff, week.matchDifferential + diff.last],
    );
    return fold;
  }

  List<MapDifferential> buildMapDifferentialForWeeks() => weeks.fold(
        [MapDifferential.zero],
        (diff, week) => [
          ...diff,
          week.mapDifferential + diff.last,
        ],
      );
}

sealed class SeasonDetails {
  const SeasonDetails();

  Iterable<OwlWeek> get weeks => switch (this) {
        StagesSeason(:final stages) => stages.expand((stage) => stage.weeks),
        WeeksSeason(:final seasonWeeks) => seasonWeeks,
      };
}

class StagesSeason extends SeasonDetails {
  final List<OwlStage> stages;

  const StagesSeason(this.stages);
}

class WeeksSeason extends SeasonDetails {
  final List<OwlWeek> seasonWeeks;

  const WeeksSeason(this.seasonWeeks);
}

class OwlSeason {
  final String name;
  final String teamName;
  final WinLossRecord winLossRecord;
  final SeasonDetails details;

  factory OwlSeason.fromJson(String seasonName, Map<String, dynamic> json) {
    final owlStages = <OwlStage>[];

    for (final stage in json['regular_season_stages']) {
      owlStages.add(OwlStage.fromJson(stage));
    }

    return OwlSeason(
      name: seasonName,
      teamName: json['team_name'],
      winLossRecord: WinLossRecord.fromJson(json),
      details: StagesSeason(owlStages),
    );
  }

  factory OwlSeason.season3(Map<String, dynamic> json) {
    final owlWeeks = <OwlWeek>[];

    final regularSeason = json['2020: Regular Season'];

    for (final week in regularSeason['weeks']) {
      owlWeeks.add(OwlWeek.fromJson(week));
    }

    return OwlSeason(
      name: 'Season 3',
      teamName: json['team_name'],
      winLossRecord: WinLossRecord.fromJson(regularSeason),
      details: WeeksSeason(owlWeeks),
    );
  }

  const OwlSeason({
    required this.name,
    required this.teamName,
    required this.winLossRecord,
    required this.details,
  });

  Iterable<OwlWeek> get weeks => details.weeks;
}

class OwlStage {
  final String name;
  final WinLossRecord winLossRecord;
  final List<OwlWeek> weeks;

  OwlStage({
    required this.name,
    required this.winLossRecord,
    required this.weeks,
  });

  factory OwlStage.fromJson(Map<String, dynamic> json) {
    return OwlStage(
      name: json['name'],
      winLossRecord: WinLossRecord.fromJson(json),
      weeks: (json['weeks'] as List<dynamic>)
          .map((week) => OwlWeek.fromJson(week))
          .toList(),
    );
  }
}

class OwlWeek {
  final String name;
  final WinLossRecord winLossRecord;

  OwlWeek({required this.name, required this.winLossRecord});

  factory OwlWeek.fromJson(Map<String, dynamic> json) {
    return OwlWeek(
      name: json['name'],
      winLossRecord: WinLossRecord.fromJson(json),
    );
  }

  MapWins get mapWins => winLossRecord.mapWins;
  MapLosses get mapLosses => winLossRecord.mapLosses;

  MatchWins get matchWins => winLossRecord.matchWins;
  MatchLosses get matchLosses => winLossRecord.matchLosses;

  MapDifferential get mapDifferential => MapDifferential(mapWins, mapLosses);
  MatchDifferential get matchDifferential =>
      MatchDifferential(matchWins, matchLosses);
}
