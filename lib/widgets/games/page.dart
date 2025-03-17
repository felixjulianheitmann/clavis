import 'package:flutter/material.dart';
import 'package:gamevault_web/widgets/games/games_list.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.games_title)),
      body: GamesList(games: ["game 1", "game 2"]),
    );
  }
}
