import 'package:clavis/l10n/app_localizations.dart';
import 'package:clavis/src/blocs/users_bloc.dart';
import 'package:clavis/src/repositories/user_repository.dart';
import 'package:clavis/src/util/helpers.dart';
import 'package:clavis/src/util/user_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});
  static const _cardSpacing = 16.0;
  static const _defaultTileWidth = 400.0;

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    return BlocProvider(
      create:
          (ctx) => UsersBloc(ctx.read<UserRepository>())..add(UsersSubscribe()),
      child: BlocBuilder<UsersBloc, UsersState>(
        builder: (context, state) {
          final api = Helpers.getApi(context);
          if (api == null) return Center(child: CircularProgressIndicator());
          if (state is! UsersReady) {
            context.read<UsersBloc>().add(UsersReload(api: api));
            return Center(child: CircularProgressIndicator());
          }

          final users = state.users;

          if (users.isEmpty) {
            // when would that happen?
            return Align(
              alignment: Alignment.topCenter,
              child: Text(translate.users_no_users_available),
            );
          }

          final deletedUsers = users.where((u) => u.user.deletedAt != null);
          final availableUsers = users.where((u) => u.user.deletedAt == null);
          final activeUsers = availableUsers.where((u) => u.user.activated);
          final inactiveUsers = availableUsers.where((u) => !u.user.activated);

          final screenW = MediaQuery.of(context).size.width;
          final singleCol = screenW < 2 * _defaultTileWidth;
          final width = singleCol ? screenW * 0.95 : _defaultTileWidth;

          Widget userTileList(List<UserBundle> users) {
            final userTiles =
                users.map((u) {
                  return UserTile(user: u, width: singleCol ? null : width);
                }).toList();

            return Wrap(
              runSpacing: _cardSpacing,
              spacing: _cardSpacing,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: userTiles,
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  userTileList(activeUsers.toList()),
                  Headline('Inactive Users'),
                  Divider(),
                  userTileList(inactiveUsers.toList()),
                  Headline('Deleted Users'),
                  Divider(),
                  userTileList(deletedUsers.toList()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class Headline extends StatelessWidget {
  const Headline(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16),
          child: Text(text, style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }
}
