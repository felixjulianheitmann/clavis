import 'package:clavis/l10n/app_localizations.dart';
import 'package:clavis/src/blocs/game_bloc.dart';
import 'package:clavis/src/blocs/user_bloc.dart';
import 'package:clavis/src/repositories/games_repository.dart';
import 'package:clavis/src/util/helpers.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';
import 'package:intl/intl.dart';

class GameProgressCard extends StatelessWidget {
  const GameProgressCard({super.key, required this.gameId});

  final num gameId;

  @override
  Widget build(BuildContext context) {
    final loader = Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(child: CircularProgressIndicator()),
      ),
    );

    final api = Helpers.getApi(context);
    if (api == null) return loader;

    return BlocProvider(
      create:
          (context) =>
              GameBloc(gameRepo: context.read<GameRepository>(), id: gameId)
                ..add(GameSubscribe(api: api))
                ..add(GameReload(api: api, id: gameId)),
      child: BlocBuilder<GameBloc, GameState>(
        builder: (context, gameState) {
          return BlocBuilder<UserMeBloc, UserState>(
            builder: (context, state) {
              if (gameState is! GameReady || state is! Ready) {
                return loader;
              }
              final me = state.user.user;
              final game = gameState.game;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _GameProgressCardBody(game: game, me: me),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _GameProgressCardBody extends StatelessWidget {
  const _GameProgressCardBody({required this.game, required this.me});

  final GamevaultGame game;
  final GamevaultUser me;

  @override
  Widget build(BuildContext context) {
    final averagePlaytime = game.metadata?.averagePlaytime ?? 0.0;
    final downloadCount = game.downloadCount;

    final myProgress = game.progresses.firstWhereOrNull(
      (p) => p.user?.id == me.id,
    );
    final lastPlayed = myProgress?.lastPlayedAt;
    final minutesPlayed = myProgress?.minutesPlayed ?? 0;
    final locale = Localizations.localeOf(context).languageCode;
    final lastPlayedStr =
        (lastPlayed != null)
            ? DateFormat.yMEd(locale).format(lastPlayed)
            : "--";

    final translate = AppLocalizations.of(context)!;

    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ValuePairs(
            labels: [
              translate.game_last_played_label,
              translate.game_average_playtime_label,
              translate.game_minutes_played_label,
            ],
            icons: [Icons.calendar_today, Icons.timer, Icons.hourglass_empty],
            values: [
              lastPlayedStr,
              translate.game_average_playtime_value(averagePlaytime),
              translate.game_minutes_played_value(minutesPlayed),
            ],
            height: 32,
          ),
          Column(
            children: [
              Row(children: [Icon(Icons.download), Text("$downloadCount")]),
            ],
          ),
        ],
      ),
    );
  }
}

class _ValuePairs extends StatelessWidget {
  const _ValuePairs({
    required this.labels,
    required this.icons,
    required this.values,
    required this.height,
  });
  final List<String> labels;
  final List<IconData> icons;
  final List<String> values;
  final double height;

  Widget _text(String text, Alignment align) {
    return SizedBox(
      height: height,
      child: Align(alignment: align, child: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final labelTexts = labels.map((e) => _text(e, Alignment.centerRight));

    final iconWidgets = icons.map(
      (e) => SizedBox(height: height, child: Icon(e)),
    );

    final valueTexts = values.map((e) => _text(e, Alignment.centerLeft));

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labelTexts.toList(),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: iconWidgets.toList(),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: valueTexts.toList(),
          ),
        ),
      ],
    );
  }
}
