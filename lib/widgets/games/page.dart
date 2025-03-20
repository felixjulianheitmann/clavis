import 'package:flutter/material.dart';
import 'package:gamevault_client_sdk/openapi.dart';
import 'package:gamevault_web/widgets/games/games_list.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    var builder = GamevaultGameBuilder();
    builder.title = "Assassin's Creed";
    builder.downloadCount = 3;
    builder.createdAt = DateTime.now();
    builder.entityVersion = 2;
    builder.filePath = "/some/path";
    builder.size = "Seom";
    builder.type = GamevaultGameTypeEnum.WINDOWS_SETUP;
    var metaBuilder = GameMetadataBuilder();
    metaBuilder.ageRating = 16;
    metaBuilder.description = "Be the assassin you want to be";
    metaBuilder.rating = 8.8;
    metaBuilder.createdAt = DateTime.now();
    metaBuilder.entityVersion = 2;
    metaBuilder.providerSlug = "someslug";
    metaBuilder.title = "Assassin'S Creed";
    metaBuilder.earlyAccess = false;

    final games = List.generate(10, (id) {
      metaBuilder.id = id;
      builder.id = id;
      return (metaBuilder.build(), builder.build());
    });
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.games_title)),
      body: GamesList(games: games),
    );
  }
}
