import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:owl_history/src/owl_team.dart';

class TeamsLoader extends ValueNotifier<TeamsLoaderState> {
  TeamsLoader() : super(Loading()) {
    unawaited(loadFiles());
  }

  Future<void> loadFiles() async {
    final filePaths = Directory('assets/teams')
        .listSync()
        .whereType<File>()
        .map((file) => file.absolute.path);

    final owlTeams = <Future<OwlTeam>>[];

    for (final path in filePaths) {
      final future = compute(_parseJsonFileToTeam, path);

      owlTeams.add(future);
    }

    var wait = await owlTeams.wait;
    value = Success(wait);
  }
}

OwlTeam _parseJsonFileToTeam(String filePath) => OwlTeam.fromJson(
      jsonDecode(File(filePath).readAsStringSync()),
    );

sealed class TeamsLoaderState {}

class Loading extends TeamsLoaderState {}

class Success extends TeamsLoaderState {
  final List<OwlTeam> teams;

  Success(this.teams);
}

class Error extends TeamsLoaderState {}
