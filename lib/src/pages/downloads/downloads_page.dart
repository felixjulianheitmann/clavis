import 'package:clavis/l10n/app_localizations.dart';
import 'package:clavis/src/pages/downloads/download_card_active.dart';
import 'package:clavis/src/pages/downloads/download_card_closed.dart';
import 'package:clavis/src/pages/downloads/download_card_pending.dart';
import 'package:clavis/src/pages/downloads/downloads_list.dart';
import 'package:flutter/widgets.dart';

class DownloadsPage extends StatelessWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DownloadsPageBody();
  }
}

class DownloadsPageBody extends StatelessWidget {
  const DownloadsPageBody({super.key});

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;

    return Column(
      children: [
        DownloadCardActive(),
        DownloadsList<DownloadCardPending>(
          title: translate.page_downloads_pending_title,
          startCollapsed: false,
        ),
        DownloadsList<DownloadCardClosed>(
          title: translate.page_downloads_closed_title,
          description: translate.page_downloads_closed_descriptions,
        ),
      ],
    );
  }
}