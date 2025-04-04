import 'package:clavis/blocs/auth_bloc.dart';
import 'package:clavis/util/credential_store.dart';
import 'package:clavis/widgets/app_title.dart';
import 'package:flutter/material.dart';
import 'package:clavis/widgets/drawer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class _LogoutAction extends StatelessWidget {
  const _LogoutAction();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        await CredentialStore.remove();
        context.read<AuthBloc>().add(AuthRemovedEvent());
      },
      icon: Icon(Icons.logout),
    );
  }
}

class ClavisScaffold extends StatelessWidget {
  const ClavisScaffold({
    super.key,
    required this.body,
    this.showDrawer = true,
    this.showAppBar = true,
  });

  final bool showAppBar;
  final bool showDrawer;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget? appBar;
    if (showAppBar) {
      appBar = AppBar(
        title: AppTitle(),
        actions: [_LogoutAction()],
      );
    }
    return Scaffold(
      appBar: appBar,
      drawer: showDrawer ? SidebarDrawer() : null,
      body: body,
    );
  }
}
