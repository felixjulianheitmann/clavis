import 'dart:io';

import 'package:clavis/l10n/app_localizations.dart';
import 'package:clavis/src/blocs/auth_bloc.dart';
import 'package:clavis/src/blocs/user_bloc.dart';
import 'package:clavis/src/repositories/user_repository.dart';
import 'package:clavis/src/util/helpers.dart';
import 'package:clavis/src/util/hoverable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditableAvatar extends StatelessWidget {
  const EditableAvatar({super.key, required this.user});

  final UserBundle user;

  static const _size = 90.0;

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Hoverable(
          foreground: SizedBox.square(
            dimension: _size * 2,
            child: Center(
              child: Tooltip(
                message: translate.action_upload_avatar,
                child: _UploadAvatarButton(userId: user.user.id),
              ),
            ),
          ),
          background: Center(child: Helpers.avatar(user.avatar, radius: _size)),
        ),
      ],
    );
  }
}

class _UploadAvatarButton extends StatelessWidget {
  const _UploadAvatarButton({required this.userId});

  final num userId;

  Future<(Stream<List<int>>, PlatformFile)?> _selectAvatar(
    BuildContext context,
  ) async {
    final translate = AppLocalizations.of(context)!;

    final pickWithStream =
        kIsWeb || !Platform.isMacOS; // macos doesn't support withReadStream
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: translate.dialog_select_avatar_title,
      type: FileType.image,
      withData: !pickWithStream,
      withReadStream: pickWithStream,
    );

    if (result == null || result.files.isEmpty) return null;

    Stream<List<int>> fileStream;
    if (pickWithStream) {
      fileStream = result.files.first.readStream!;
    } else {
      fileStream = Stream<List<int>>.fromIterable([
        result.files.first.bytes!.toList(),
      ]);
    }

    return (fileStream, result.files.first);
  }

  @override
  Widget build(BuildContext context) {
    final api = context.select((AuthBloc a) {
      if (a is Authenticated) return (a as Authenticated).api;
    });

    void Function()? onPress;
    if (api != null) {
      onPress = () async {
        final fileSelection = await _selectAvatar(context);
        if (fileSelection == null) return;
        if (context.mounted) {
          context.read<UserBloc>().add(
            UploadAvatar(
              api: api,
              fileStream: fileSelection.$1,
              file: fileSelection.$2,
            ),
          );
        }
      };
    }

    return FloatingActionButton(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: CircleBorder(),
      onPressed: onPress,
      child: Icon(Icons.edit),
    );
  }
}
