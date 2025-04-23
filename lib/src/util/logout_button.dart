import 'package:clavis/src/blocs/auth_bloc.dart';
import 'package:clavis/src/blocs/page_bloc.dart';
import 'package:clavis/src/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LogoutAction extends StatelessWidget {
  const LogoutAction({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        context.read<AuthBloc>().add(Logout());
        context.read<PageBloc>().add(
          PageChanged(Constants.gamesPageInfo()),
        );
      },
      icon: Icon(Icons.logout),
    );
  }
}
