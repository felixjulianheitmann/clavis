import 'package:clavis/l10n/app_localizations.dart';
import 'package:clavis/src/blocs/auth_bloc.dart';
import 'package:clavis/src/blocs/users_bloc.dart';
import 'package:clavis/src/repositories/user_repository.dart';
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
          final api = context.select((AuthBloc a) {
            if (a.state is Authenticated) {
              return (a.state as Authenticated).api;
            }
          });

          if (state is! UsersReady) {
            if (api != null) {
              context.read<UsersBloc>().add(UsersReload(api: api));
            }
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
          final alignment =
              singleCol ? WrapAlignment.center : WrapAlignment.start;
          final width = singleCol ? screenW * 0.95 : _defaultTileWidth;

          Widget userTileList(List<UserBundle> users) {
            final userTiles =
                users.map((u) => UserTile(user: u, width: width)).toList();

            return SizedBox(
              width: double.maxFinite,
              child: Wrap(
                runSpacing: _cardSpacing,
                spacing: _cardSpacing,
                alignment: alignment,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: userTiles,
              ),
            );
          }

          return SingleChildScrollView(
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

class UserTile extends StatelessWidget {
  const UserTile({super.key, required this.user, required this.width});
  final UserBundle user;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) {
                return BlocProvider(
                  create: (ctx) {
                    return UserBloc(ctx.read<UserRepository>(), user.user.id)
                      ..add(Subscribe());
                  },
                  child: DetailPage(id: user.user.id),
                );
              },
            ),
          ),
      child: Focusable(
        child: SizedBox(
          width: width,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 8,
                children: [UserAvatar(user), UserDesc(user.user)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  const UserAvatar(this.user, {super.key});
  final UserBundle user;

  static const size = 50.0;

  @override
  Widget build(BuildContext context) {
    IconData? icon;
    if (!user.user.activated) icon = Icons.close;
    if (user.user.deletedAt != null) icon = Icons.delete;
    return Stack(
      children: [
        Helpers.avatar(user.avatar, radius: size),
        Visibility(
          visible: icon != null,
          child: Opacity(
            opacity: 0.7,
            child: Icon(icon ?? Icons.check, size: size * 2),
          ),
        ),
      ],
    );
  }
}

class UserDesc extends StatelessWidget {
  const UserDesc(this.user, {super.key});
  final GamevaultUser user;

  Widget _username(String username) {
    return Opacity(
      opacity: 0.6,
      child: Text("@$username", textScaler: TextScaler.linear(1.2)),
    );
  }

  Widget _userTitle(GamevaultUser user) {
    if (user.firstName == null && user.lastName == null) {
      return Text("");
    }
    return Text(Helpers.userTitle(user));
  }

  Widget _userRole(GamevaultUserRoleEnum role, BuildContext context) {
    switch (role) {
      case GamevaultUserRoleEnum.n0:
        return Text("?????");
      case GamevaultUserRoleEnum.n1:
        return Text("standard");
      case GamevaultUserRoleEnum.n2:
        return Text("?????");
      case GamevaultUserRoleEnum.n3:
        return Text("admin");
    }
    return Text(AppLocalizations.of(context)!.users_unknown_role);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _username(user.username),
        _userTitle(user),
        Text(user.birthDate?.toString() ?? ""),
        Text(user.email ?? ""),
        _userRole(user.role, context),
      ],
    );
  }
}
