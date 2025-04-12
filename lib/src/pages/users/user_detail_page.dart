import 'package:clavis/src/blocs/auth_bloc.dart';
import 'package:clavis/l10n/app_localizations.dart';
import 'package:clavis/src/blocs/user_bloc.dart';
import 'package:clavis/src/pages/users/user_detail_form.dart';
import 'package:clavis/src/pages/users/user_editable_avatar.dart';
import 'package:clavis/src/repositories/user_repository.dart';
import 'package:clavis/src/clavis_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key, required this.id});
  final num id;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserBloc(context.read<UserRepository>(), id),
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, userState) {
          final translate = AppLocalizations.of(context)!;
          if (userState is! Ready) {
            return Center(child: CircularProgressIndicator());
          }

          final user = userState.user;

          return ClavisScaffold(
            showDrawer: false,
            actions: [
              DeactivateButton(translate: translate, id: id),
              DeleteButton(translate: translate, id: id),
            ],
            body: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [EditableAvatar(user: user)],
                ),
                UserForm(user: user.user),
              ],
            ),
          );
        },
      ),
    );
  }
}

class DeleteButton extends StatelessWidget {
  const DeleteButton({super.key, required this.translate, required this.id});

  final AppLocalizations translate;
  final num id;

  @override
  Widget build(BuildContext context) {
    final api = context.select((AuthBloc a) {
      if (a is Authenticated) return (a as Authenticated).api;
    });

    void Function()? onPress;
    if (api != null) {
      onPress = () {
        context.read<UserBloc>().add(Delete(api: api));
      };
    }

    return Tooltip(
      message: translate.action_delete,
      child: IconButton(onPressed: onPress, icon: Icon(Icons.delete)),
    );
  }
}

class DeactivateButton extends StatelessWidget {
  const DeactivateButton({
    super.key,
    required this.translate,
    required this.id,
  });

  final AppLocalizations translate;
  final num id;

  @override
  Widget build(BuildContext context) {
    final api = context.select((AuthBloc a) {
      if (a is Authenticated) return (a as Authenticated).api;
    });

    void Function()? onPress;
    if (api != null) {
      onPress = () {};
    }

    return Tooltip(
      message: translate.action_deactivate,
      child: IconButton(icon: Icon(Icons.block), onPressed: onPress),
    );
  }
}
