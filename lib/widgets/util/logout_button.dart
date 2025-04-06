import 'package:clavis/blocs/auth_bloc.dart';
import 'package:clavis/util/credential_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LogoutAction extends StatelessWidget {
  const LogoutAction({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        await CredentialStore.remove();
        if (context.mounted) {
          context.read<AuthBloc>().add(AuthCredChangedEvent());
        }
      },
      icon: Icon(Icons.logout),
    );
  }
}
