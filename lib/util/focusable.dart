import 'package:flutter/material.dart';

class Focusable extends StatefulWidget {
  const Focusable({super.key, required this.child});
  final Widget child;

  @override
  State<Focusable> createState() => _FocusableState();
}

class _FocusableState extends State<Focusable> {
  bool _isHovering = false;

  static const _hoverFactor = 1.1;
  static const _animationDuration = Duration(milliseconds: 100);

  @override
  Widget build(BuildContext context) {
    var scale = _isHovering ? _hoverFactor : 1.0;

    return MouseRegion(
      onEnter: (e) => setState(() => _isHovering = true),
      onExit: (e) => setState(() => _isHovering = false),
      child: AnimatedScale(
        scale: scale,
        duration: _animationDuration,
        child: widget.child,
      ),
    );
  }
}
