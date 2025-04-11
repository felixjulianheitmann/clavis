import 'package:clavis/blocs/auth_bloc.dart';
import 'package:clavis/src/repositories/credential_repository.dart';
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
