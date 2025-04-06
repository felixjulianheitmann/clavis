import 'dart:io';
import 'dart:math';

import 'package:clavis/blocs/auth_bloc.dart';
import 'package:clavis/blocs/error_bloc.dart';
import 'package:clavis/blocs/user_bloc.dart';
import 'package:clavis/blocs/users_bloc.dart';
import 'package:clavis/l10n/app_localizations.dart';
import 'package:clavis/util/helpers.dart';
import 'package:clavis/util/hoverable.dart';
import 'package:clavis/util/logger.dart';
import 'package:clavis/widgets/clavis_scaffold.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_email_validator/email_validator.dart';
import 'package:gamevault_client_sdk/api.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key, required this.user, required this.initState});
  final GamevaultUser user;
  final AuthState initState;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc(initialState: initState)),
        BlocProvider(create: (context) => UserBloc(initialUser: user)),
      ],
      child: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          final translate = AppLocalizations.of(context)!;
          if (state is UserUpdateFailedState) {
            final snack = SnackBar(
              content: Text(state.error.toString()),
              action: SnackBarAction(
                label: translate.action_close,
                backgroundColor: Theme.of(context).colorScheme.error,
                onPressed:
                    () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snack);
          }

          if (state is UserDeletedState) {
            Navigator.pop(context);
          }
        },
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, userState) {
            return BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                final translate = AppLocalizations.of(context)!;
                return ClavisScaffold(
                  showDrawer: false,
                  actions: [
                    Tooltip(
                      message: translate.action_deactivate,
                      child: IconButton(
                        icon: Icon(Icons.block),
                        onPressed: () {},
                      ),
                    ),

                    Tooltip(
                      message: translate.action_delete,
                      child: IconButton(
                        onPressed: () {
                          if (userState.user != null &&
                              authState is AuthSuccessState) {
                            context.read<UserBloc>().add(
                              UserDeletedEvent(
                                user: userState.user!,
                                api: authState.api,
                              ),
                            );
                          }
                        },
                        icon: Icon(Icons.delete),
                      ),
                    ),
                  ],
                  body: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [_EditableAvatar()],
                      ),
                      _UserForm(),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _UserForm extends StatefulWidget {
  const _UserForm();

  @override
  State<_UserForm> createState() => _UserFormState();
}

typedef _UserFormBuilderFunc =
    Widget Function(
      BuildContext context,
      bool readOnly,
      AuthSuccessState? authState,
      GamevaultUser user,
    );

Widget _withBlocs(_UserFormBuilderFunc builder) {
  return BlocBuilder<AuthBloc, AuthState>(
    builder: (context, authState) {
      AuthSuccessState? authSuccess;
      bool readOnly = true;
      if (authState is AuthSuccessState) {
        authSuccess = authState;
        readOnly = false;
      }

      return BlocBuilder<UserBloc, UserState>(
        builder: (context, userState) {
          if (userState is UserUpdatingState) readOnly = true;

          if (userState is UserReadyState) {
            return builder(context, readOnly, authSuccess, userState.user);
          } else if (userState is UserUpdateFailedState) {
            return builder(context, readOnly, authSuccess, userState.user);
          } else if (userState is UserUpdatingState) {
            return builder(context, readOnly, authSuccess, userState.user);
          }

          log.e("User info is an undefined state", error: userState);
          return SizedBox.shrink(); // What else is there to do?
        },
      );
    },
  );
}

String? Function(String?) _forbidEmpty(String emptyMessage) {
  return (String? text) {
    if (text == null || text.isEmpty) {
      return emptyMessage;
    }
    return null;
  };
}

String? _validateMail(String? text, invalidMailMessage) {
  // empty field is allowed
  if (text == null || text.isEmpty) return null;

  if (!EmailValidator.validate(text)) {
    return invalidMailMessage;
  }
  return null;
}

class _UserFormState extends State<_UserForm> {
  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    return _withBlocs((context, readOnly, authState, user) {
      return SizedBox(
        width: min(MediaQuery.of(context).size.width, 400),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                TextEdit(
                  label: translate.page_user_details_username,
                  initialValue: user.username,
                  submitter: (v) => UpdateUserDto(username: v),
                  valueGetter: (user) => user.username,
                  validator: _forbidEmpty(
                    translate.validation_error_field_empty,
                  ),
                ),
                TextEdit(
                  label: translate.page_user_details_firstname,
                  initialValue: user.firstName,
                  submitter: (v) => UpdateUserDto(firstName: v),
                  valueGetter: (user) => user.firstName,
                ),
                TextEdit(
                  label: translate.page_user_details_lastname,
                  initialValue: user.lastName,
                  submitter: (v) => UpdateUserDto(lastName: v),
                  valueGetter: (user) => user.lastName,
                ),
                TextEdit(
                  label: translate.page_user_details_email,
                  initialValue: user.email,
                  submitter: (v) => UpdateUserDto(email: v),
                  valueGetter: (user) => user.email,
                  validator:
                      (v) =>
                          _validateMail(v, translate.validation_invalid_mail),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class TextEdit extends StatefulWidget {
  const TextEdit({
    super.key,
    required this.label,
    required this.submitter,
    required this.valueGetter,
    required this.initialValue,
    this.validator,
  });

  final String label;
  final String? initialValue;
  final UpdateUserDto Function(String) submitter;
  final String? Function(GamevaultUser) valueGetter;
  final String? Function(String? text)? validator;

  @override
  State<TextEdit> createState() => _TextEditState();
}

class _TextEditState extends State<TextEdit> {
  final _ctrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isModified = false;

  @override
  void initState() {
    _ctrl.text = widget.initialValue ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _withBlocs((context, readOnly, authState, user) {
      void onSubmit(UpdateUserDto userUpdate) {
        context.read<UserBloc>().add(
          UserChangedEvent(
            user: user,
            update: userUpdate,
            api: authState!.api,
          ), // authState! mutually exclusive with readOnly
        );
      }

      return BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserReadyState) {
            // check on state updates
            setState(() {
              final remote = widget.valueGetter(user);
              _isModified = remote != null && remote != _ctrl.text;
            });
          }
        },
        child: Form(
          key: _formKey,
          child: TextFormField(
            validator: widget.validator,
            readOnly: readOnly,
            controller: _ctrl,
            onChanged:
                (v) => setState(
                  () => _isModified = widget.valueGetter(user) != _ctrl.text,
                ),
            onFieldSubmitted: (v) {
              if (_formKey.currentState!.validate()) {
                onSubmit(widget.submitter(v));
              }
            },
            decoration: InputDecoration(
              labelText: widget.label,
              suffixIcon: _isModified ? Icon(Icons.pending) : null,
            ),
          ),
        ),
      );
    });
  }
}

class _EditableAvatar extends StatelessWidget {
  const _EditableAvatar();

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
        _withBlocs((context, readOnly, authState, user) {
          final translate = AppLocalizations.of(context)!;
          return Hoverable(
            foreground: Visibility(
              visible: !readOnly,
              child: SizedBox.square(
                dimension: _size * 2,
                child: Center(
                  child: Tooltip(
                    message: translate.action_upload_avatar,
                    child: FloatingActionButton(
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      shape: CircleBorder(),
                      onPressed:
                          () async => await _uploadAvatar(
                            context,
                            user.id,
                            authState!.api,
                            authState.me,
                          ),
                      child: Icon(Icons.edit),
                    ),
                  ),
                ),
              ),
            ),
            background: Center(child: Helpers.avatar(user, radius: _size)),
          );
        }),
      ],
    );
  }
}
