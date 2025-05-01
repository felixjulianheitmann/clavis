import 'package:clavis/src/pages/users/users_page.dart';
import 'package:flutter/material.dart';

class HeadlineDivider extends StatelessWidget {
  const HeadlineDivider({super.key, required this.text});

  final String text;

  static const _gap = 8.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: Divider(thickness: 4, indent: _gap, endIndent: _gap,)),
        Headline(text),
        Expanded(child: Divider(thickness: 4, indent: _gap, endIndent: _gap,)),
      ],
    );
  }
}
