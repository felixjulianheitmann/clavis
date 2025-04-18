import 'package:clavis/src/blocs/download_bloc.dart';
import 'package:clavis/src/pages/downloads/download_card_base.dart';
import 'package:clavis/src/repositories/download_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DownloadCardActive extends StatelessWidget {
  const DownloadCardActive({super.key});

  @override
  Widget build(BuildContext context) {
    final activeOp = context.select((DownloadBloc d) {
      return d.state.dlContext.activeOp;
    });

    if (activeOp == null) return SizedBox.shrink();

    return DownloadCardBase(
      operation: activeOp,
      overlay: _ProgressDisplay(operation: activeOp),
      children: [
    ]);
  }
}

class _ProgressDisplay extends StatelessWidget {
  const _ProgressDisplay({required this.operation});

  final DownloadOp operation;

  @override
  Widget build(BuildContext context) {
    return Text("Progresss");
  }
}
