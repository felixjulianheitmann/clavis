import 'package:clavis/l10n/app_localizations.dart';
import 'package:clavis/src/blocs/download_bloc.dart';
import 'package:clavis/src/blocs/pref_bloc.dart';
import 'package:clavis/src/pages/downloads/download_card_base.dart';
import 'package:clavis/src/repositories/download_repository.dart';
import 'package:clavis/src/util/helpers.dart';
import 'package:clavis/src/util/value_pair_column.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';

class DownloadCardPending extends StatelessWidget {
  const DownloadCardPending({super.key, required this.operation});
  final DownloadOp operation;

  @override
  Widget build(BuildContext context) {
    return DownloadCardBase(
      operation: operation,
      children: [
        _GameInfo(game: operation.game),
        Column(
          children: [
            _DownloadButton(operation: operation),
            _RemoveButton(gameId: operation.game.id),
          ],
        ),
      ],
    );
  }
}

class _GameInfo extends StatelessWidget {
  const _GameInfo({required this.game});

  final GamevaultGame game;
  static const _titleScaling = 2.0;

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;

    return Column(
      children: [
        Text(game.title ?? "", textScaler: TextScaler.linear(_titleScaling)),
        ValuePairColumn(
          labels: [translate.download_size_label],
          icons: [Icons.storage],
          values: [Helpers.sizeStrInUnit(game.size!, translate)],
          height: 24,
        ),
      ],
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.gameId});

  final num gameId;

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;

    return Tooltip(
      message: translate.action_remove,
      child: IconButton.filled(
        onPressed:
            () => context.read<DownloadBloc>().add(
              DlRemovePending(gameId: gameId),
            ),
        icon: Icon(Icons.delete),
      ),
    );
  }
}

class _DownloadButton extends StatelessWidget {
  const _DownloadButton({required this.operation});

  final DownloadOp operation;

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;

    final api = Helpers.getApi(context);
    final downloadDir = context.select(
      (PrefBloc p) => p.state.prefs.downloadDir,
    );
    final enableButtons = api != null && downloadDir != null;

    return Tooltip(
      message: translate.action_download,
      child: IconButton.filled(
        onPressed:
            enableButtons
                ? () => context.read<DownloadBloc>().add(
                  DlAdd(
                    api: api,
                    downloadDir: downloadDir,
                    game: operation.game,
                  ),
                )
                : null,
        icon: Icon(Icons.download),
      ),
    );
  }
}
