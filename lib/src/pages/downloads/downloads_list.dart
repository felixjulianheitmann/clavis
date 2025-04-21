import 'package:clavis/l10n/app_localizations.dart';
import 'package:clavis/src/blocs/download_bloc.dart';
import 'package:clavis/src/pages/downloads/download_card_base.dart';
import 'package:clavis/src/pages/downloads/download_card_closed.dart';
import 'package:clavis/src/pages/downloads/download_card_pending.dart';
import 'package:clavis/src/repositories/download_repository.dart';
import 'package:clavis/src/util/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DownloadsList<CardType> extends StatelessWidget {
  const DownloadsList({
    super.key,
    required this.title,
    this.description,
    this.startCollapsed = true,
  });
  final String title;
  final String? description;
  final bool startCollapsed;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(title),
      subtitle: description != null ? Text(description!) : null,
      initiallyExpanded: !startCollapsed,
      children: [_List<CardType>()],
    );
  }
}

class _List<CardType> extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ops = context.select((DownloadBloc d) {
      if (CardType is DownloadCardPending) return d.state.dlContext.pendingOps;
      if (CardType is DownloadCardClosed) return d.state.dlContext.closedOps;
      return <DownloadOp>[];
    });

    final translate = AppLocalizations.of(context)!;
    if (ops.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16),
        child: Text(translate.list_empty_message),
      );
    }

    Iterable<DownloadCardBase>? items;
    if (CardType is DownloadCardPending) {
      items = ops.map(
        (op) => DownloadCardPending(operation: op) as DownloadCardBase,
      );
    } else if (CardType is DownloadCardClosed) {
      items = ops.map(
        (op) => DownloadCardClosed(operation: op) as DownloadCardBase,
      );
    } else {
      log.e("Unknownw download widget type", error: CardType);
    }

    return Column(children: items?.toList() ?? []);
  }
}
