import 'dart:io';

import 'package:clavis/blocs/auth_bloc.dart';
import 'package:clavis/blocs/error_bloc.dart';
import 'package:clavis/blocs/users_bloc.dart';
import 'package:clavis/l10n/app_localizations.dart';
import 'package:clavis/util/helpers.dart';
import 'package:clavis/util/hoverable.dart';
import 'package:clavis/widgets/clavis_scaffold.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key, required this.user, required this.initState});
  final GamevaultUser user;
  final AuthState initState;

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => AuthBloc(initialState: initState),
      child: ClavisScaffold(
        title: translate.page_user_details_title,
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
      ),
    );
  }
}

class _EditableAvatar extends StatelessWidget {
  const _EditableAvatar({required this.user});
  final GamevaultUser user;

  static const _size = 90.0;

  Future<void> _uploadAvatar(
    BuildContext context,
    num userId,
    ApiClient api,
    GamevaultUser me,
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

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    Stream<List<int>> fileStream;
    if (pickWithStream) {
      fileStream = result.files.first.readStream!;
    } else {
      fileStream = Stream<List<int>>.fromIterable([
        result.files.first.bytes!.toList(),
      ]);
    }

    try {
      final uploaded = await MediaApi(api).postMedia(
        file: MultipartFile(
          "file",
          ByteStream(fileStream),
          file.size,
          filename: file.name,
          contentType: MediaType("image", file.extension ?? "png"),
        ),
      );
      if (uploaded == null) {
        if (context.mounted) {
          ErrorBloc.makeError(
            context,
            "upload of avatar returned with null",
            true,
          );
        }
        return;
      }

      GamevaultUser? result;
      if (userId == me.id) {
        result = await UserApi(
          api,
        ).putUsersMe(UpdateUserDto(avatarId: uploaded.id));
      } else {
        result = await UserApi(
          api,
        ).putUserByUserId(userId, UpdateUserDto(avatarId: uploaded.id));
      }

      if (result == null) {
        if (context.mounted) {
          ErrorBloc.makeError(
            context,
            "updating user with new avatar returned with null",
            true,
          );
        }
        return;
      }

      if (context.mounted) {
        context.read<UsersBloc>().add(UsersChangedEvent());
      }
    } catch (e) {
      if (context.mounted) {
        ErrorBloc.makeError(context, e, true);
      }
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Hoverable(
          foreground: SizedBox.square(
            dimension: _size * 2,
            child: Center(
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is! AuthSuccessState) {
                    return const SizedBox.shrink();
                  }
                  return FloatingActionButton(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    shape: CircleBorder(),
                    onPressed:
                        () async => await _uploadAvatar(
                          context,
                          user.id,
                          state.api,
                          state.me,
                        ),
                    child: Icon(Icons.edit),
                  );
                },
              ),
            ),
          ),
          background: Center(child: Helpers.avatar(user, radius: _size)),
        ),
      ],
    );
  }
}
