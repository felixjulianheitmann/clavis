import 'package:clavis/widgets/settings/app_settings.dart';
import 'package:clavis/widgets/settings/gamevault_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const _tabSwitchWidth = 800;

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;
    if (width < _tabSwitchWidth) {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: TabBar(
            tabs: [
              Tab(text: translate.settings_app_title),
              Tab(text: translate.settings_gamevault_title),
            ],
          ),
          body: TabBarView(children: [AppSettings(), GamevaultSettings()]),
        ),
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(child: AppSettings()),
          Divider(),
          Expanded(child: GamevaultSettings()),
        ],
      );
    }
  }
}
