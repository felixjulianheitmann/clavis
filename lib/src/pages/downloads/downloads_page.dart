import 'package:clavis/l10n/app_localizations.dart';
import 'package:clavis/src/blocs/download_bloc.dart';
import 'package:clavis/src/clavis_scaffold.dart';
import 'package:flutter/widgets.dart';

class DownloadsPage extends StatelessWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;

    return ClavisScaffold(
      body: DownloadsPageBody(),
      title: translate.page_downloads_title,
      showDrawer: false,
    );
  }
}

class DownloadsPageBody extends StatelessWidget {
  const DownloadsPageBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}