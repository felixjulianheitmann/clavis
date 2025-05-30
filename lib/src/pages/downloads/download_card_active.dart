import 'dart:collection';

import 'package:clavis/l10n/app_localizations.dart';
import 'package:clavis/src/blocs/download_bloc.dart';
import 'package:clavis/src/util/game_info_card.dart';
import 'package:clavis/src/repositories/download_repository.dart';
import 'package:clavis/src/util/helpers.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DownloadCardActive extends StatelessWidget {
  const DownloadCardActive({super.key});

  static const _cardHeight = 200.0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloadBloc, DownloadState>(
      builder: (context, state) {
        if (!state.dlContext.hasActive) return SizedBox.shrink();
        return GameInfoCard(
          height: _cardHeight,
          gameId: state.dlContext.activeOp!.game.id,
          overlay: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(top: 32),
              child: _ProgressDisplay(
                operation: state.dlContext.activeOp!,
                height: _cardHeight,
              ),
            ),
          ),
          child: Expanded(
            child: _DownloadData(activeOp: state.dlContext.activeOp!),
          ),
        );
      },
    );
  }
}

class _DownloadData extends StatelessWidget {
  const _DownloadData({required this.activeOp});

  final DownloadOp activeOp;

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    final p = activeOp.progress;
    final mapper = Helpers.sizeUnitMapper(p.bytesTotal, translate);
    final totalBytes = mapper(p.bytesTotal);
    final loadedBytes = mapper(p.bytesLoaded);
    final dlSpeed = p.speeds.isNotEmpty ? p.speeds.last.$1 : 0.0;

    final r =
        dlSpeed == 0.0
            ? Duration.zero
            : Duration(
              seconds: ((p.bytesTotal - p.bytesLoaded) / dlSpeed).toInt(),
            );

    final style = TextStyle(fontSize: 20, fontFamily: 'RobotoMono');

    return Row(
      spacing: 8,
      mainAxisSize: MainAxisSize.max,
      children: [
        Card.outlined(
          color: Theme.of(context).canvasColor.withAlpha(150),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("$loadedBytes/$totalBytes", style: style),
                Text(Helpers.speedInUnit(dlSpeed, translate), style: style),
                Text(Helpers.formatDuration(r), style: style),
              ],
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton.filled(onPressed: null, icon: Icon(Icons.pause)),
            IconButton.filled(
              onPressed: () => context.read<DownloadBloc>().add(DlCancel()),
              icon: Icon(Icons.close),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProgressDisplay extends StatelessWidget {
  const _ProgressDisplay({required this.operation, required this.height});

  final DownloadOp operation;
  final double height;

  @override
  Widget build(BuildContext context) {
    final dlSpeeds = operation.progress.speeds.indexed.map((pair) {
      return FlSpot(pair.$1.toDouble(), pair.$2.$1);
    });

    final color = Theme.of(context).primaryColor;

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minY: 0.0,
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0), color],
                stops: const [0.3, 1.0],
              ),
              dotData: FlDotData(show: false),
              spots: dlSpeeds.toList(),
              barWidth: 8,
              isCurved: false,
              curveSmoothness: 0.35,
            ),
          ],
          lineTouchData: LineTouchData(enabled: false),
        ),
        duration: Duration.zero,
        transformationConfig: FlTransformationConfig(),
      ),
    );

    // return ShaderMask(
    //   shaderCallback: (rect) {
    //     return LinearGradient(
    //       colors: [Colors.transparent, Colors.black],
    //     ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
    //   },
    //   child: LineChart(
    //     LineChartData(
    //       lineBarsData: [
    //         LineChartBarData(spots: spotsSpeed.toList()),
    //         LineChartBarData(spots: spotsSpeedAvg.toList()),
    //       ],
    //     ),
    //   ),
    // );
  }
}
