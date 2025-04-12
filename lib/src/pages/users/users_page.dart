import 'package:clavis/l10n/app_localizations.dart';
import 'package:clavis/src/blocs/auth_bloc.dart';
import 'package:clavis/src/blocs/users_bloc.dart';
import 'package:clavis/src/repositories/user_repository.dart';
import 'package:clavis/src/util/focusable.dart';
import 'package:clavis/src/util/helpers.dart';
import 'package:clavis/src/pages/users/user_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});
  static const _cardSpacing = 16.0;

  List<UserTile> userTiles(UserBundles users) {
    return users.map((user) => UserTile(user: user)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (ctx) => UsersBloc(ctx.read<UserRepository>())..add(Subscribe()),
      child: BlocBuilder<UsersBloc, UsersState>(
        builder: (context, state) {
          final api = context.select((AuthBloc a) {
            if (a.state is Authenticated) {
              return (a.state as Authenticated).api;
            }
          });

          if (state is! Ready) {
            if (api != null) {
              context.read<UsersBloc>().add(Reload(api: api));
            }
            return Center(child: CircularProgressIndicator());
          }

          final users = state.users;
          
          if (users.isEmpty) { // when would that happen?
            return Align(
              alignment: Alignment.topCenter,
              child: Text(translate.users_no_users_available),
            );
          }

          return SizedBox(
            width: double.maxFinite,
            child: Wrap(
              runSpacing: _cardSpacing,
              spacing: _cardSpacing,
              alignment: WrapAlignment.spaceEvenly,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: userTiles(users),
            ),
          );

        },
      ),
    );
  }
}

class UserTile extends StatelessWidget {
  const UserTile({super.key, required this.user});
  final UserBundle user;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailPage(id: user.user.id),
            ),
          ),
      child: Focusable(
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
    );
  }
}

class UserAvatar extends StatelessWidget {
  const UserAvatar(this.user, {super.key});
  final UserBundle user;

  static const size = 50.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Helpers.avatar(user.avatar, radius: size),
        Visibility(
          visible: !user.user.activated,
          child: Opacity(
            opacity: 0.7,
            child: Icon(Icons.close, size: size * 2),
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
