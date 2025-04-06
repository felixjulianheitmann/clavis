import 'package:flutter/material.dart';

class Hoverable extends StatefulWidget {
  const Hoverable({
    super.key,
    required this.background,
    required this.foreground,
    this.alignment,
  });
  final Widget background;
  final Widget foreground;
  final AlignmentGeometry? alignment;

  @override
  State<Hoverable> createState() => _HoverableState();
}

class _HoverableState extends State<Hoverable> {
  static const _animDuration = Duration(milliseconds: 1000);

  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => setState(() => _isHovering = true),
      onExit: (event) => setState(() => _isHovering = false),
      child: Stack(
        alignment: widget.alignment ?? AlignmentDirectional.topStart,
        children: [
          widget.background,
          AnimatedOpacity(
            opacity: _isHovering ? 1 : 0,
            duration: _animDuration,
            child: widget.foreground,
          ),
        ],
      ),
    );
  }
}
