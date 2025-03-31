import 'package:clavis/widgets/app_title.dart';
import 'package:clavis/widgets/clavis_scaffold.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const _pagePadding = EdgeInsets.all(12.0);

  @override
  Widget build(BuildContext context) {
    return ClavisScaffold(body: Padding(padding: _pagePadding, child: AppTitle()), showDrawer: false,);
  }
}