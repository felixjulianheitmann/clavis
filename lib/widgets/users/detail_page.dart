import 'package:clavis/util/helpers.dart';
import 'package:clavis/util/hoverable.dart';
import 'package:clavis/widgets/clavis_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:gamevault_client_sdk/api.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key, required this.user});
  final GamevaultUser user;

  @override
  Widget build(BuildContext context) {
    return ClavisScaffold(
      showDrawer: false,
      actions: [IconButton(onPressed: () {}, icon: Icon(Icons.delete))],
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [_EditableAvatar(user: user)],
          ),
        ],
      ),
    );
  }
}

class _EditableAvatar extends StatelessWidget {
  const _EditableAvatar({required this.user});
  final GamevaultUser user;

  static const _size = 90.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Hoverable(
          foreground: SizedBox.square(
            dimension: _size * 2,
            child: Center(
              child: FloatingActionButton(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                shape: CircleBorder(),
                onPressed: () {},
                child: Icon(Icons.edit),
              ),
            ),
          ),
          background: Center(child: Helpers.avatar(user, radius: _size)),
        ),
      ],
    );
  }
}
