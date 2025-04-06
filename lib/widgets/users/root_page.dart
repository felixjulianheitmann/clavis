import 'package:clavis/blocs/auth_bloc.dart';
import 'package:clavis/blocs/error_bloc.dart';
import 'package:clavis/blocs/users_bloc.dart';
import 'package:clavis/l10n/app_localizations.dart';
import 'package:clavis/util/focusable.dart';
import 'package:clavis/util/helpers.dart';
import 'package:clavis/widgets/query_builder.dart';
import 'package:clavis/widgets/users/detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});
  static const _cardSpacing = 16.0;

  List<UserTile> userTiles(List<GamevaultUser> users) {
    return users.map((user) => UserTile(user: user)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    return Querybuilder(
      query: (api) => UserApi(api).getUsers(),
      builder: (context, users, error) {
        if (users == null) {
          return Align(
            alignment: Alignment.topCenter,
            child: Text(translate.users_no_users_available),
          );
        }

        final api = context.select((AuthBloc auth) {
          if (auth.state is AuthSuccessState) {
            return (auth.state as AuthSuccessState).api;
          }
          return null;
        });
        if (api == null) {
          ErrorBloc.makeError(
            context,
            "couldn't find authentication credentials ... y tho?",
            true,
          );
          return Center(child: CircularProgressIndicator());
        }

        return BlocProvider(
          create: (_) => UsersBloc(users: users, api: api),
          child: BlocBuilder<UsersBloc, UsersState>(
            builder: (context, state) {
              state.users.sort((a, b) => a.username.compareTo(b.username));

              if (!state.isInitialized) {
                return Center(child: CircularProgressIndicator());
              }

              return SizedBox(
                width: double.maxFinite,
                child: Wrap(
                  runSpacing: _cardSpacing,
                  spacing: _cardSpacing,
                  alignment: WrapAlignment.spaceEvenly,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: userTiles(state.users),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class UserTile extends StatelessWidget {
  const UserTile({super.key, required this.user});
  final GamevaultUser user;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return GestureDetector(
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailPage(user: user, initState: state),
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
                  children: [UserAvatar(user), UserDesc(user)],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class UserAvatar extends StatelessWidget {
  const UserAvatar(this.user, {super.key});
  final GamevaultUser user;

  static const size = 50.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Helpers.avatar(user, radius: size),
        Visibility(
          visible: !user.activated,
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
