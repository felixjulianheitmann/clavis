import 'package:clavis/src/blocs/auth_bloc.dart';
import 'package:clavis/l10n/app_localizations.dart';
import 'package:clavis/src/blocs/user_bloc.dart';
import 'package:clavis/src/pages/users/user_detail_form.dart';
import 'package:clavis/src/pages/users/user_editable_avatar.dart';
import 'package:clavis/src/repositories/user_repository.dart';
import 'package:clavis/src/clavis_scaffold.dart';
import 'package:clavis/src/util/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key, required this.id});
  final num id;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              UserBloc(context.read<UserRepository>(), id)..add(Subscribe()),
      child: ClavisScaffold(
        showDrawer: false,
        actions: [ActivationButton(id: id), DeleteButton(id: id)],
        body: BlocBuilder<UserBloc, UserState>(
          builder: (context, userState) {
            final api = context.select((AuthBloc a) {
              if (a.state is Authenticated) {
                return (a.state as Authenticated).api;
              }
            });

            if (userState is! Ready) {
              if (api != null) context.read<UserBloc>().add(Reload(api: api));
              return Center(child: CircularProgressIndicator());
            }

            final user = userState.user;

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [EditableAvatar(user: user)],
                ),
                UserForm(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class DeleteButton extends StatelessWidget {
  const DeleteButton({super.key, required this.id});

  final num id;

  @override
  Widget build(BuildContext context) {
    final api = Helpers.getApi(context);

    void Function()? onPress;
    if (api != null) {
      onPress = () {
        context.read<UserBloc>().add(Delete(api: api));
      };
    }

    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is Deleted) Navigator.pop(context);
      },
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          Widget button = IconButton(
            onPressed: onPress,
            icon: Icon(Icons.delete),
          );

          if (state is Deleting) button = CircularProgressIndicator();

          return Tooltip(
            message: AppLocalizations.of(context)!.action_delete,
            child: button,
          );
        },
      ),
    );
  }
}

class ActivationButton extends StatelessWidget {
  const ActivationButton({super.key, required this.id});

  final num id;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        final api = Helpers.getApi(context);
        if (state is! Ready || api == null) return CircularProgressIndicator();

        String tooltip;
        IconData icon;
        UserEvent buttonEvent;

        if (!state.user.user.activated) {
          tooltip = AppLocalizations.of(context)!.action_activate;
          icon = Icons.how_to_reg;
          buttonEvent = Activate(api: api);
        } else {
          tooltip = AppLocalizations.of(context)!.action_deactivate;
          icon = Icons.block;
          buttonEvent = Deactivate(api: api);
        }

        return Tooltip(
          message: tooltip,
          child: IconButton(
            icon: Icon(icon),
            onPressed: () {
              context.read<UserBloc>().add(buttonEvent);
            },
          ),
        );
      },
    );
  }
}
