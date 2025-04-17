import 'package:clavis/src/blocs/download_bloc.dart';
import 'package:clavis/src/pages/downloads/download_card_closed.dart';
import 'package:clavis/src/pages/downloads/download_card_pending.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClosedDownloadsList<CardType> extends StatelessWidget {
  const ClosedDownloadsList({super.key, required this.title, this.description });
  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(title),
      subtitle: description!= null ? Text(description!) : null,
      children: [_List<CardType>()],
    );
  }
}

class _List<CardType> extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloadBloc, DownloadState>(
      builder: (context, state) {
        final items = state.dlContext.pendingOps.map((op) {
          if(CardType is DownloadCardPending)
          {return DownloadCardPending(operation: op);}
          else {
            return DownloadCardClosed(operation: op);
          }
        });

        return Column(children: items.toList());
      },
    );
  }
}
