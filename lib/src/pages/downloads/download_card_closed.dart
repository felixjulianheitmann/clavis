import 'package:clavis/l10n/app_localizations.dart';
import 'package:clavis/src/blocs/download_bloc.dart';
import 'package:clavis/src/blocs/pref_bloc.dart';
import 'package:clavis/src/util/game_info_card.dart';
import 'package:clavis/src/repositories/download_repository.dart';
import 'package:clavis/src/util/helpers.dart';
import 'package:clavis/src/util/value_pair_column.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';

class DownloadCardClosed extends StatelessWidget {
  const DownloadCardClosed({super.key, required this.operation});
  final DownloadOp operation;

  @override
  Widget build(BuildContext context) {
    return GameInfoCard(
      height: 150,
      gameId: operation.game.id,
      child: Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                _GameInfo(
                  game: operation.game,
                  status: operation.status,
                  duration: operation.stopped.difference(operation.started),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _RetryButton(operation: operation),
                _RemoveButton(gameId: operation.game.id),
              ],
            ),
          ],
        ),
      )
    );
  }
}

class _GameInfo extends StatelessWidget {
  const _GameInfo({
    required this.game,
    required this.status,
    required this.duration,
  });

  final GamevaultGame game;
  final DownloadStatus status;
  final Duration duration;
  static const _titleScaling = 2.0;
  
  (String, IconData) _statusMap(AppLocalizations tr) {
    switch (status) {
      case DownloadStatus.finished:
        return (tr.download_status_finished, Icons.check);
      case DownloadStatus.pending:
        return (tr.download_status_pending, Icons.hourglass_empty_rounded);
      case DownloadStatus.running:
        return (tr.download_status_running, Icons.play_arrow);
      case DownloadStatus.cancelled:
        return (tr.download_status_cancelled, Icons.cancel);
      case DownloadStatus.downloadReturnedError:
        return (tr.download_status_downloadReturnedError, Icons.error);
      case DownloadStatus.unknown:
        return (tr.download_status_unknown, Icons.question_mark);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    final downloadStatus = _statusMap(translate);

    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(game.title ?? "", textScaler: TextScaler.linear(_titleScaling)),
          ValuePairColumn(
            labels: [
              translate.download_size_label,
              translate.download_status_label,
              translate.download_duration_label,
            ],
            icons: [
              Icons.storage,
              downloadStatus.$2,
              Icons.hourglass_bottom_rounded,
            ],
            values: [
              Helpers.sizeStrInUnit(game.size!, translate),
              downloadStatus.$1,
              Helpers.formatDuration(duration),
            ],
            height: 24,
          ),
        ],
      ),
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
              DlRemoveClosed(gameId: gameId),
            ),
        icon: Icon(Icons.close),
      ),
    );
  }
}

class _RetryButton extends StatelessWidget {
  const _RetryButton({required this.operation});

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
                  DlRetry(gameId: operation.game.id,
                  ),
                )
                : null,
        icon: Icon(Icons.replay),
      ),
    );
  }
}
