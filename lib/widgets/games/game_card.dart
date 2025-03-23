import 'package:flutter/material.dart';
import 'package:gamevault_client_sdk/api.dart';

class GameCard extends StatelessWidget {
  const GameCard({super.key, required this.metadata, required this.game});
  static const width = 150.0;
  static const aspect = 0.7;

  final GameMetadata metadata;
  final GamevaultGame game;

  @override
  Widget build(BuildContext context) {
    return Card(
      // margin: EdgeInsets.all(12),
      child: Column(children: [Text(game.title ?? "Unknown")]),
    );
  }
}
