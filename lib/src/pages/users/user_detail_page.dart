import 'package:clavis/l10n/app_localizations.dart';
import 'package:clavis/src/blocs/user_bloc.dart';
import 'package:clavis/src/pages/users/user_detail_form.dart';
import 'package:clavis/src/pages/users/user_editable_avatar.dart';
import 'package:clavis/src/clavis_scaffold.dart';
import 'package:clavis/src/util/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key, this.id});
  final num? id;

  @override
  Widget build(BuildContext context) {

    Widget builder(BuildContext context, UserState userState) {
      final api = Helpers.getApi(context);

      if (userState is! Ready || api == null) {
        return Center(child: CircularProgressIndicator());
      }

      Helpers.getUserSpecificBloc(context, id).add(Reload(api: api));

      final user = userState.user;

      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [EditableAvatar(user: user)],
          ),
          UserForm(id: id),
        ],
      );
    }

    return BlocProvider(
      create: (ctx) => Helpers.getUserSpecificBloc(ctx, id)..add(Subscribe()),
      child: ClavisScaffold(
        showDrawer: false,
        actions: [ActivationButton(id: id), DeletionButton(id: id)],
        body: UserSpecificBlocBuilder(id: id, builder: builder),
      ),
    );
  }
}

class DeletionButton extends StatelessWidget {
  const DeletionButton({super.key, this.id});

  final num? id;

  @override
  Widget build(BuildContext context) {
    final api = Helpers.getApi(context);
    return UserSpecificBlocBuilder(
      id: id,
      builder: (context, state) {
        if (state is! Ready || api == null) return CircularProgressIndicator();
        String tooltip;
        IconData icon;
        UserEvent buttonEvent;

        if (state.user.user.deletedAt == null) {
          tooltip = AppLocalizations.of(context)!.action_delete;
          icon = Icons.delete;
          buttonEvent = Delete(api: api);
        } else {
          tooltip = AppLocalizations.of(context)!.action_restore;
          icon = Icons.restore;
          buttonEvent = Restore(api: api);
        }

        return Tooltip(
          message: tooltip,
          child: IconButton(
            onPressed:
                () => Helpers.getUserSpecificBloc(context, id).add(buttonEvent),
            icon: Icon(icon),
          ),
        );
      },
    );
  }
}

class ActivationButton extends StatelessWidget {
  const ActivationButton({super.key, this.id});

  final num? id;

  @override
  Widget build(BuildContext context) {
    return UserSpecificBlocBuilder(
      id: id,
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
              Helpers.getUserSpecificBloc(context, id).add(buttonEvent);
            },
          ),
        );
      },
    );
  }
}

