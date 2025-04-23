import 'package:clavis/l10n/app_localizations.dart';
import 'package:clavis/src/blocs/active_download_bloc.dart';
import 'package:clavis/src/blocs/page_bloc.dart';
import 'package:clavis/src/constants.dart';
import 'package:clavis/src/repositories/download_repository.dart';
import 'package:clavis/src/util/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

double _currentSpeed(Progress progress) {
  if (progress.speeds.isEmpty) return 0.0;
  return progress.speeds.last.$1;
}

SnackBar activeDlSnackbar(BuildContext context) {
  return SnackBar(
    padding: EdgeInsets.zero,
    backgroundColor: Theme.of(context).canvasColor,
    behavior: SnackBarBehavior.fixed,
    duration: Duration(days: 365), // do not close automatically
    content: BlocBuilder<ActiveDlBloc, ActiveDlState>(
      builder: (context, state) {
        final activeDl = state.operation;
        final translate = AppLocalizations.of(context)!;
        if (activeDl == null) return SizedBox.shrink();
        final mapper = Helpers.sizeUnitMapper(
          activeDl.progress.bytesTotal,
          translate,
        );
        final current = _currentSpeed(activeDl.progress);
        final loaded = mapper(activeDl.progress.bytesLoaded);
        final total = mapper(activeDl.progress.bytesTotal);

        final textStyle = TextStyle(
          fontFamily: 'RobotoMono',
          color: Theme.of(context).textTheme.bodyMedium!.color,
        );

        final name = activeDl.game.title ?? activeDl.game.id.toString();
        final dlSpeedText = Helpers.speedInUnit(current, translate);
        final dlProgressText = "$loaded / $total";

        final w = TextPainter.computeWidth(
          text: TextSpan(
            style: textStyle,
            children: [
              TextSpan(text: Helpers.speedInUnit(current, translate)),
              TextSpan(text: dlSpeedText),
              TextSpan(text: dlProgressText),
            ],
          ),
          textDirection: TextDirection.ltr,
        );

        var snackContent = [
          Text(name, style: textStyle),
          Text(dlSpeedText, style: textStyle),
          Text(dlProgressText, style: textStyle),
        ];
        final showName = w < MediaQuery.of(context).size.width * 0.7;
        if (!showName) snackContent.removeAt(0);

        return GestureDetector(
          onTap: () {
            context.read<PageBloc>().add(
              PageChanged(Constants.downloadsPageInfo()),
            );
            Navigator.pop(context);
          },
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: snackContent,
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
