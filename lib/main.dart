import 'package:flutter/material.dart';
import 'package:owl_history/src/teams_loader.dart';
import 'package:owl_history/src/win_loss_record.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
  runApp(const MaterialApp(home: MainApp()));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final loader = TeamsLoader();

  @override
  void dispose() {
    loader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ValueListenableBuilder<TeamsLoaderState>(
          valueListenable: loader,
          builder: (context, value, child) {
            return switch (value) {
              Loading() => StreamBuilder(
                  stream: Stream.periodic(const Duration(seconds: 1), (i) => i),
                  builder: (context, snapshot) => Text(
                    snapshot.data.toString(),
                  ),
                ),
              Success(:final teams) => SfCartesianChart(
                  primaryXAxis: const CategoryAxis(),
                  series: teams
                      .map(
                        (team) => LineSeries<MapDifferential, int>(
                          dataSource: team.buildMapDifferentialForWeeks(),
                          color: team.primaryColor,
                          xValueMapper: (_, index) {
                            return index;
                          },
                          yValueMapper: (mapDiff, index) => mapDiff.value,
                        ),
                      )
                      .toList(),
                ),
              Error() => const SizedBox(),
            };
          },
        ),
      ),
    );
  }
}
