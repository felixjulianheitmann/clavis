import 'package:flutter/material.dart';
import 'package:gamevault_client_sdk/api.dart';
import 'package:gamevault_web/widgets/games/game_page.dart';

class GameCard extends StatefulWidget {
  const GameCard({super.key, required this.game});

  final GamevaultGame game;

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  static const _width = 350.0;
  static const _hoverFactor = 1.1;
  static const _animationDuration = Duration(milliseconds: 100);
  bool _isHovering = false;

  Image _cover() {
    final url = widget.game.metadata?.cover?.sourceUrl;
    if (url == null) {
      return Image.asset("Key-Logo_Diagonal.png", width: _width);
    }
    return Image.network(url, width: _width);
  }

  @override
  Widget build(BuildContext context) {
    var scale = 1.0;
    if (_isHovering) {
      scale = _hoverFactor;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (ctx) => GamePage(game: widget.game)),
        );
      },
      child: MouseRegion(
        onEnter: (e) => setState(() => _isHovering = true),
        onExit: (e) => setState(() => _isHovering = false),
        child: AnimatedScale(
          scale: scale,
          duration: _animationDuration,
          child: Card(
            clipBehavior: Clip.antiAlias,
            semanticContainer: true,
            child: _cover(),
          ),
        ),
      ),
    );
  }
}
