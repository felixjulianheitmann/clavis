import 'package:flutter/material.dart';

class GamesList extends StatelessWidget {
  const GamesList({super.key, required this.games});

  final List<String> games;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children:
          games.map((game) {
            return ListTile(title: Text(game));
          }).toList(),
     );
  }
}
