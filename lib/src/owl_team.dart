import 'dart:ui';

import 'package:owl_history/src/win_loss_record.dart';

class OwlTeam {
  final String name;
  final Color primaryColor;
  final WinLossRecord winLossRecord;
  final List<OwlStage> stages;

  OwlTeam({
    required this.name,
    required this.stages,
    required this.winLossRecord,
    required this.primaryColor,
  });

  factory OwlTeam.fromJson(Map<String, dynamic> json) {
    final owlStages = <OwlStage>[];
    final teamName = json['team_name'];
    final <String, dynamic>{'r': int r, 'g': int g, 'b': int b} =
        json['primary_color'];

    final primaryColor = Color.fromRGBO(r, g, b, 1);

    for (final stage in json['regular_season_stages']) {
      owlStages.add(OwlStage.fromJson(stage));
    }

    return OwlTeam(
      name: teamName,
      winLossRecord: WinLossRecord.fromJson(json),
      primaryColor: primaryColor,
      stages: owlStages,
    );
  }

  Iterable<OwlWeek> get weeks => stages.expand((stage) => stage.weeks);

  List<MatchDifferential> buildMatchDifferentialForWeeks() {
    var fold = weeks.fold(
      [MatchDifferential.zero],
      (diff, week) => diff..add(week.matchDifferential + diff.last),
    );
    return fold;
  }

  List<MapDifferential> buildMapDifferentialForWeeks() => weeks.fold(
        [MapDifferential.zero],
        (diff, week) => diff..add(week.mapDifferential + diff.last),
      );
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
