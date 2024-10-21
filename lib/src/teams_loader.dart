import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'owl_team.dart';

class TeamsLoader extends ValueNotifier<TeamsLoaderState> {
  TeamsLoader() : super(Loading()) {
    unawaited(loadFiles());
  }

  Future<void> loadFiles() async {
    final stopwatch = Stopwatch()..start();
    final filePaths = Directory('assets/teams')
        .listSync()
        .whereType<File>()
        .map((file) => file.absolute.path);

    final owlTeams = <Future<OwlTeam>>[];

    for (final path in filePaths) {
      final future = compute(_parseJsonFileToTeam, path);

      owlTeams.add(future);
    }

    final wait = await owlTeams.wait;
    stopwatch.stop();
    debugPrint('Full setup time: ${stopwatch.elapsed}');
    value = Success(wait);
  }
}

OwlTeam _parseJsonFileToTeam(String filePath) {
  final fileContent = File(filePath).readAsStringSync();

  return OwlTeam.fromJson(jsonDecode(fileContent));
}

sealed class TeamsLoaderState {}

final class Loading extends TeamsLoaderState {}

class Success extends TeamsLoaderState {
  final List<OwlTeam> teams;

  Success(this.teams);
}

class Error extends TeamsLoaderState {}
