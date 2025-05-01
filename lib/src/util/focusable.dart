import 'package:flutter/material.dart';

typedef FocusWrapper = Widget Function(Widget child);
class Focusable extends StatefulWidget {
  const Focusable({super.key, this.onTap, required this.builder});
  final void Function()? onTap;
  final Widget Function(BuildContext context, FocusWrapper focus) builder;

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

    Widget focusWrapper(Widget child) {
      return AnimatedScale(
        scale: scale,
        duration: _animationDuration,
        child: child,
      );
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (e) => setState(() => _isHovering = true),
        onExit: (e) => setState(() => _isHovering = false),
        child: widget.builder(context, focusWrapper),
      ),
    );
  }
}
