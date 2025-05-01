import 'package:clavis/l10n/app_localizations.dart';
import 'package:clavis/src/blocs/user_bloc.dart';
import 'package:clavis/src/pages/users/user_detail_page.dart';
import 'package:clavis/src/repositories/user_repository.dart';
import 'package:clavis/src/util/focusable.dart';
import 'package:clavis/src/util/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';

class UserTile extends StatelessWidget {
  const UserTile({super.key, required this.user});
  final UserBundle user;

  static const width = 400.0;

  @override
  Widget build(BuildContext context) {
    return Focusable(
      onTap: () {
        Navigator.push(
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
        );
      },
      child: SizedBox(
        width: UserTile.width,
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
