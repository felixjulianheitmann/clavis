import 'package:clavis/util/helpers.dart';
import 'package:flutter/material.dart';
import 'package:gamevault_client_sdk/api.dart';
import 'package:clavis/widgets/games/game_page.dart';

class GameCard extends StatefulWidget {
  const GameCard({super.key, required this.game, this.width = defaultWidth});

  final GamevaultGame game;
  final double width;
  static const defaultWidth = 150.0;
  static const aspectRatio = 1.3;
  static const minWidth = 50.0;
  static const maxWidth = 400.0;

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  static const _hoverFactor = 1.1;
  static const _animationDuration = Duration(milliseconds: 100);
  bool _isHovering = false;

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
          child: SizedBox(
            height: GameCard.aspectRatio * widget.width,
            width: widget.width,
            child: Card(
              clipBehavior: Clip.antiAlias,
              semanticContainer: true,
              child: Helpers.cover(widget.game, widget.width),
            ),
              ),
            ),
      ),
    );
  }
}
