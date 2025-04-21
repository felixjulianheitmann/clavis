import 'package:clavis/l10n/app_localizations.dart';
import 'package:clavis/src/blocs/active_download_bloc.dart';
import 'package:clavis/src/blocs/page_bloc.dart';
import 'package:clavis/src/constants.dart';
import 'package:clavis/src/pages/downloads/util.dart';
import 'package:clavis/src/repositories/download_repository.dart';
import 'package:clavis/src/util/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

double _currentSpeed(Progress progress) {
  if (progress.speeds.isEmpty) return 0.0;
  return progress.speeds.last.$1;
}

SnackBar activeDlSnackbar() {
  return SnackBar(
    behavior: SnackBarBehavior.floating,
    duration: Duration(
      days: 1000,
    ), // TODO: How do I prevent it from being closed
    content: BlocBuilder<ActiveDlBloc, ActiveDlState>(
      builder: (context, state) {
        final activeDl = state.operation;
        final translate = AppLocalizations.of(context)!;
        if (activeDl == null) return SizedBox.shrink();

        final current = _currentSpeed(activeDl.progress);
        final loaded = activeDl.progress.bytesLoaded;
        final sizeStrs = Helpers.sizeInUnitUniform([
          loaded,
          activeDl.progress.bytesTotal,
        ], translate);

        return GestureDetector(
          onTap: () {
            context.read<PageBloc>().add(
              PageChangedEvent(Constants.downloadsPageInfo()),
            );
            Navigator.pop(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(activeDl.game.title ?? activeDl.game.id.toString()),
              Text(Helpers.speedInUnit(current, translate)),
              Text("${sizeStrs[0]} / ${sizeStrs[1]}"),
            ],
          ),
        );
      },
    ),
  );
}
