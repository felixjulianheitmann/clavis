import 'package:clavis/src/blocs/user_bloc.dart';
import 'package:clavis/src/pages/users/user_detail_page.dart';
import 'package:clavis/src/repositories/user_repository.dart';
import 'package:clavis/src/util/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserMePage extends StatelessWidget {
  const UserMePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              UserMeBloc(context.read<UserRepository>())..add(Subscribe()),
      child: BlocBuilder<UserMeBloc, UserState>(
        builder: (context, state) {
          if (state is! Ready) return CircularProgressIndicator();
          return Column(children: [Helpers.avatar(state.user.avatar)]);
        },
      ),
    );
  }
}

class UserEditAction extends StatelessWidget {
  const UserEditAction({super.key});

  @override
  Widget build(BuildContext context) {
    void onPressed() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailPage(id: null)),
      );
    }

    return IconButton(onPressed: onPressed, icon: Icon(Icons.edit));
  }
}
