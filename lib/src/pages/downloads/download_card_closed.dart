
import 'package:clavis/l10n/app_localizations.dart';
import 'package:clavis/src/blocs/download_bloc.dart';
import 'package:clavis/src/blocs/pref_bloc.dart';
import 'package:clavis/src/repositories/download_repository.dart';
import 'package:clavis/src/util/cache_image.dart';
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
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          _BackgroundBanner(game: operation.game),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Helpers.cover(operation.game, 50),
                _GameInfo(game: operation.game),
                Column(
                  children: [
                    _DownloadButton(operation: operation),
                    _RemoveButton(gameId: operation.game.id),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
          values: [Helpers.sizeInUnit(game.size, translate)],
          height: 24,
        ),
      ],
    );
  }
}

class _BackgroundBanner extends StatelessWidget {
  const _BackgroundBanner({required this.game});

  final GamevaultGame game;

  @override
  Widget build(BuildContext context) {
    final backgroundUrl = game.metadata?.background?.sourceUrl;
    Widget background;
    if (backgroundUrl != null) {
      background = Expanded(child: CacheImage(imageUrl: backgroundUrl));
    } else {
      background = SizedBox.shrink();
    }

    return FittedBox(fit: BoxFit.cover, child: background);
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
            () => context.read<DownloadBloc>().add(DlRemove(gameId: gameId)),
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
