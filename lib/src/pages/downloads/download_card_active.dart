import 'dart:collection';
import 'dart:math';

import 'package:clavis/src/blocs/active_download_bloc.dart';
import 'package:clavis/src/blocs/download_bloc.dart';
import 'package:clavis/src/pages/downloads/download_card_base.dart';
import 'package:clavis/src/pages/downloads/util.dart';
import 'package:clavis/src/repositories/download_repository.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DownloadCardActive extends StatefulWidget {
  const DownloadCardActive({super.key});

  @override
  State<DownloadCardActive> createState() => _DownloadCardActiveState();
}

class _DownloadCardActiveState extends State<DownloadCardActive> {
  @override
  Widget build(BuildContext context) {

    return BlocBuilder<DownloadBloc, DownloadState>(
      builder: (context, state) {
        if (!state.dlContext.hasActive) return SizedBox.shrink();
        return _ProgressDisplay(operation: state.dlContext.activeOp!);
      },
    );

    // return DownloadCardBase(
    //   operation: activeOp,
    //   children: [
    // ]);
  }
}

class _ProgressDisplay extends StatelessWidget {
  const _ProgressDisplay({required this.operation});

  final DownloadOp operation;

  @override
  Widget build(BuildContext context) {
    final dlSpeeds = operation.progress.speeds.indexed.map((pair) {
      return FlSpot(pair.$1.toDouble(), pair.$2.$1);
    });

    final color = Theme.of(context).primaryColor;

    return SizedBox(
      height: 400,
      width: 10000,
      child: LineChart(
        LineChartData(
          minY: 0.0,

          gridData: FlGridData(drawVerticalLine: false),
          titlesData: FlTitlesData(show: false),
          lineBarsData: [
            LineChartBarData(
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0), color],
                stops: const [0.1, 1.0],
              ),
              dotData: FlDotData(show: false),
              spots: dlSpeeds.toList(),
              barWidth: 8,
            ),
          ],
        ),
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
