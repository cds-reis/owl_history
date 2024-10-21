import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'src/owl_team.dart';
import 'src/teams_loader.dart';
import 'src/win_loss_record.dart';

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
                  stream: Stream.periodic(
                    const Duration(seconds: 1),
                    (i) => i + 1,
                  ),
                  initialData: 0,
                  builder: (context, snapshot) => Text(
                    snapshot.data.toString(),
                  ),
                ),
              Success(:final teams) => Chart(teams: teams),
              Error() => const SizedBox(),
            };
          },
        ),
      ),
    );
  }
}

class Chart extends StatelessWidget {
  const Chart({
    super.key,
    required this.teams,
  });

  final List<OwlTeam> teams;

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        axisLabelFormatter: (args) {
          if (args.value == 0) {
            return ChartAxisLabel('', args.textStyle);
          }

          return ChartAxisLabel(
            'Week ${args.value}',
            args.textStyle,
          );
        },
        labelPlacement: LabelPlacement.betweenTicks,
        multiLevelLabelStyle: const MultiLevelLabelStyle(
          borderType: MultiLevelBorderType.squareBrace,
        ),
        name: 'The history of the Overwatch League',
        multiLevelLabels: multiLevelLabels,
      ),
      crosshairBehavior: CrosshairBehavior(
        enable: true,
        activationMode: ActivationMode.singleTap,
        lineType: CrosshairLineType.vertical,
      ),
      enableMultiSelection: true,
      legend: const Legend(
        isVisible: true,
        isResponsive: true,
        title: LegendTitle(
          text: 'Teams',
          alignment: ChartAlignment.near,
        ),
      ),
      series: teams
          .map(
            (team) => LineSeries<MapDifferential?, int>(
              dataSource: [
                if (team.season1 == null) ...List.generate(20, (_) => null),
                ...team.buildMapDifferentialForWeeks(),
              ],
              color: team.primaryColor,
              xValueMapper: (_, index) {
                return index;
              },
              yValueMapper: (mapDiff, index) => mapDiff?.value,
              name: team.name,
              legendItemText: team.name,
              legendIconType: LegendIconType.diamond,
              width: 2.5,
            ),
          )
          .toList(),
    );
  }

  List<CategoricalMultiLevelLabel> get multiLevelLabels {
    List<CategoricalMultiLevelLabel> buildSeason(int season) {
      final seasonStart = 1 + (20 * (season - 1));
      final seasonEnd = seasonStart + 19;
      return [
        ...List.generate(
          4,
          (i) {
            final start = seasonStart + (i * 5);
            final end = start + 4;

            return CategoricalMultiLevelLabel(
              start: '$start',
              end: '$end',
              text: 'Stage ${i + 1}',
            );
          },
        ),
        CategoricalMultiLevelLabel(
          start: '$seasonStart',
          end: '$seasonEnd',
          text: 'Season $season',
          level: 1,
        ),
      ];
    }

    return [
      ...buildSeason(1),
      ...buildSeason(2),
      const CategoricalMultiLevelLabel(
        start: '41',
        end: '61',
        level: 1,
        text: 'Season 3',
      )
    ];
  }
}
