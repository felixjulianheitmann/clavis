import 'package:flutter/material.dart';
import 'package:gamevault_client_sdk/api.dart';
import 'package:clavis/widgets/clavis_scaffold.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key, required this.game});

  final GamevaultGame game;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  Widget build(BuildContext context) {
    return ClavisScaffold(
      body: Center(child: Text(widget.game.title ?? "Unknown game")),
    );
  }
}
