import 'package:clavis/widgets/settings/app_settings.dart';
import 'package:clavis/widgets/settings/gamevault_settings.dart';
import 'package:flutter/material.dart';
import 'package:clavis/l10n/app_localizations.dart';

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
          body: TabBarView(children: [AppSettingsPanel(), GamevaultSettings()]),
        ),
      );
    } else {
      return Row(
        children: [
          Expanded(child: AppSettingsPanel()),
          Expanded(child: GamevaultSettings()),
        ],
      );
    }
  }
}
