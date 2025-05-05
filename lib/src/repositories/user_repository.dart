import 'dart:async';
import 'dart:typed_data';

import 'package:clavis/src/types.dart';
import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gamevault_client_sdk/api.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';

class UserRepoException extends ClavisException {
  UserRepoException(super.msg, {super.innerException, super.stack})
    : super(prefix: 'UserRepoException');
  UserRepoException.fromHere(super.msg)
    : super(prefix: 'UserRepoException', stack: StackTrace.current);
}

class UserBundle {
  UserBundle({required this.user, this.avatar});
  GamevaultUser user;
  ImageProvider? avatar;
  UserBundle copyWith({GamevaultUser? user, ImageProvider? avatar}) =>
      UserBundle(user: user ?? this.user, avatar: avatar ?? this.avatar);
}

typedef UserBundles = List<UserBundle>;

class UserRepository {
  UserBundle? _userMe;
  UserBundles? _users;
  final _userMeController = StreamController<UserBundle>.broadcast();
  final _usersController = StreamController<List<UserBundle>>.broadcast();

  UserRepository() {
    Future(() async {
      await for (final u in _userMeController.stream.handleError((_) {
        /* errors are caught by the bloc */
      }, test: (error) => error is ClavisException)) {
        _userMe = u;
      }
    });
    Future(() async {
      await for (final ul in _usersController.stream.handleError((_) {
        /* errors are caught by the bloc */
      }, test: (error) => error is ClavisException)) {
        _users = ul;
      }
    });
  }

  Stream<UserBundle> get userMe async* {
    if (_userMe != null) yield _userMe!;
    yield* _userMeController.stream;
  }

  Stream<List<UserBundle>> get users async* {
    if (_users != null) yield _users!;
    yield* _usersController.stream;
  }

  Stream<UserBundle> user(num id) async* {
    if (_users != null) {
      final user = _users!.firstWhereOrNull((u) => u.user.id == id);
      if (user != null) yield user;
    }

    await for (final users in _usersController.stream.handleError((_) {
      /* errors are caught by the bloc */
    }, test: (error) => error is ClavisException)) {
      final user = users.firstWhereOrNull((u) => u.user.id == id);
      if (user != null) yield user;
    }
  }

  Future<void> reloadUsers(ApiClient api) async {
    List<GamevaultUser>? users;
    try {
      users = await UserApi(api).getUsers();
    } catch (e, s) {
      return _usersController.addError(
        UserRepoException("users reload failed", innerException: e, stack: s),
      );
    }
    if (users == null) {
      return _usersController.addError(
        UserRepoException.fromHere("users reload returned with null"),
      );
    }

    for (final u in users) {
      getAvatar(api, u);
    }

    final bundles = users.map((u) => UserBundle(user: u)).toList();
    _usersController.add(bundles);
  }

  void _updateUserEntry(GamevaultUser user) {
    if (_users != null) {
      final idx = _users!.indexWhere((u) => u.user.id == user.id);
      if (idx >= 0) {
        _users![idx] = _users![idx].copyWith(user: user);
        _usersController.add(_users!);
      }
    }
    if (_userMe != null && _userMe!.user.id == user.id) {
      _userMeController.add(_userMe!.copyWith(user: user));
    }
  }

  Future<void> getUserMe(ApiClient api) async {
    GamevaultUser? me;
    try {
      me = await UserApi(api).getUsersMe();
    } catch (e, s) {
      return _userMeController.addError(
        UserRepoException("user me query failed", innerException: e, stack: s),
      );
    }
    if (me == null) {
      return _userMeController.addError(
        UserRepoException.fromHere("user me query returned with null"),
      );
    }

    getAvatar(api, me);
    _userMeController.add(UserBundle(user: me));
  }

  Future<void> getUser(ApiClient api, num id) async {
    GamevaultUser? user;
    try {
      user = await UserApi(api).getUserByUserId(id);
    } catch (e, s) {
      return _usersController.addError(
        UserRepoException(
          "Couldn't query user info",
          innerException: e,
          stack: s,
        ),
      );
    }
    if (user == null) {
      return _usersController.addError(
        UserRepoException.fromHere("user query returned with null: $id"),
      );
    }

    _updateUserEntry(user);
  }

  Future<void> getAvatar(ApiClient api, GamevaultUser user) async {
    if (user.avatar == null) return;

    void onAvatar(ImageProvider avatar) {
      if (_users != null) {
        final idx = _users!.indexWhere((u) => u.user.id == user.id);
        if (idx >= 0) {
          _users![idx].avatar = avatar;
          _usersController.add(_users!);
        }
      }
      if (_userMe != null) {
        _userMeController.add(
          _userMe!.copyWith(user: _userMe!.user, avatar: avatar),
        );
      }
    }

    if (user.avatar!.sourceUrl != null) {
      // query internet resource
      onAvatar(NetworkImage(user.avatar!.sourceUrl!));
    }

    String? media;
    try {
      media = await MediaApi(api).getMediaByMediaId("${user.avatar!.id}");
    } catch (e, s) {
      return _usersController.addError(
        UserRepoException(
          "error querying user avatar",
          innerException: e,
          stack: s,
        ),
      );
    }
    if (media == null) {
      return _usersController.addError(
        UserRepoException.fromHere(
          "avatar query returned null response - user-id: ${user.id}",
        ),
      );
    }

    onAvatar(MemoryImage(Uint8List.fromList(media.codeUnits)));
  }

  Future<void> updateUserMe(ApiClient api, UpdateUserDto update) async {
    GamevaultUser? updatedMe;
    try {
      updatedMe = await UserApi(api).putUsersMe(update);
    } catch (e, s) {
      return _userMeController.addError(
        UserRepoException("user me update failed", innerException: e, stack: s),
      );
    }
    if (updatedMe == null) {
      return _userMeController.addError(
        UserRepoException.fromHere("user me update returned with null"),
      );
    }

    // username has been updated and will be needed for authentication
    if (update.username != null) {
      (api.authentication as HttpBasicAuth).username = update.username!;
    }
    if (update.password != null) {
      (api.authentication as HttpBasicAuth).password = update.password!;
    }
    await getUserMe(api); // reload user list
  }

  Future<void> updateUser(ApiClient api, num id, UpdateUserDto update) async {
    GamevaultUser? updatedUser;
    try {
      updatedUser = await UserApi(api).putUserByUserId(id, update);
    } catch (e) {
      return _usersController.addError(
        UserRepoException("Couldn't update user info: $e"),
      );
    }

    if (updatedUser == null) {
      return _usersController.addError(
        UserRepoException("user update returned with null"),
      );
    }

    await getUser(api, id); // reload user list
  }

  Future<void> deleteUser(ApiClient api, num id) async {
    GamevaultUser? res;
    try {
      res = await UserApi(api).deleteUserByUserId(id);
    } catch (e, s) {
      return _usersController.addError(
        UserRepoException("error deleting user", innerException: e, stack: s),
      );
    }
    if (res == null) {
      return _usersController.addError(
        UserRepoException.fromHere(
          "user deletion returned null response - user-id: $id",
        ),
      );
    }

    await reloadUsers(api);
  }

  Future<void> deleteUserMe(ApiClient api) async {
    GamevaultUser? res;
    try {
      res = await UserApi(api).deleteUserMe();
    } catch (e, s) {
      return _userMeController.addError(
        UserRepoException(
          "error deleting user me",
          innerException: e,
          stack: s,
        ),
      );
    }
    if (res == null) {
      return _userMeController.addError(
        UserRepoException.fromHere("user me deletion returned null response"),
      );
    }

    await reloadUsers(api);
  }

  Future<void> restoreUser(ApiClient api, num id) async {
    GamevaultUser? res;
    try {
      res = await UserApi(api).postUserRecoverByUserId(id);
    } catch (e, s) {
      return _usersController.addError(
        UserRepoException(
          "error restoring user - user-id: $id",
          innerException: e,
          stack: s,
        ),
      );
    }
    if (res == null) {
      return _usersController.addError(
        UserRepoException.fromHere(
          "user restoration returned null response - user-id: $id",
        ),
      );
    }

    await reloadUsers(api);
  }

  Future<void> addBookmark(ApiClient api, num id) async {
    try {
      await UserApi(api).postUsersMeBookmark(id);
    } catch (e, s) {
      return _usersController.addError(
        UserRepoException(
          "error adding bookmark: $id",
          innerException: e,
          stack: s,
        ),
      );
    }
    await getUserMe(api);
  }

  Future<void> removeBookmark(ApiClient api, num id) async {
    try {
      await UserApi(api).deleteUsersMeBookmark(id);
    } catch (e, s) {
      return _usersController.addError(
        UserRepoException(
          "error adding bookmark: $id",
          innerException: e,
          stack: s,
        ),
      );
    }
    await getUserMe(api);
  }

  Future<void> activateUser(ApiClient api, num id) async {
    try {
      final update = UpdateUserDto(activated: true);
      await updateUser(api, id, update);
    } catch (e, s) {
      return _usersController.addError(
        UserRepoException(
          "user activation failed",
          innerException: e,
          stack: s,
        ),
      );
    }
  }

  Future<void> deactivateUser(ApiClient api, num id) async {
    try {
      final update = UpdateUserDto(activated: false);
      await updateUser(api, id, update);
    } catch (e, s) {
      return _usersController.addError(
        UserRepoException(
          "user deactivation failed",
          innerException: e,
          stack: s,
        ),
      );
    }
  }

  Future<void> deactivateUserMe(ApiClient api) async {
    try {
      final update = UpdateUserDto(activated: false);
      await updateUserMe(api, update);
    } catch (e, s) {
      return _userMeController.addError(
        UserRepoException(
          "deactivating me failed",
          innerException: e,
          stack: s,
        ),
      );
    }
  }

  Future<num?> uploadAvatar(
    ApiClient api,
    Stream<List<int>> fileStream,
    PlatformFile file,
  ) async {
    Media? uploaded;
    try {
      uploaded = await MediaApi(api).postMedia(
        file: MultipartFile(
          "file",
          ByteStream(fileStream),
          file.size,
          filename: file.name,
          contentType: MediaType("image", file.extension ?? "png"),
        ),
      );
    } catch (e, s) {
      _usersController.addError(
        UserRepoException(
          "upload of avatar failed",
          innerException: e,
          stack: s,
        ),
      );
      return null;
    }

    if (uploaded == null) {
      _usersController.addError(
        UserRepoException.fromHere("upload of avatar returned with null"),
      );
      return null;
    }

    return uploaded.id;
  }

  Future<void> addUser(ApiClient api, RegisterUserDto registration) async {
    GamevaultUser? addedUser;
    try {
      addedUser = await UserApi(api).postUserRegister(registration);
    } catch (e, s) {
      return _usersController.addError(
        UserRepoException(
          "user registration failed",
          innerException: e,
          stack: s,
        ),
      );
    }
    if (addedUser == null) {
      return _usersController.addError(
        UserRepoException.fromHere("user registration returned with null"),
      );
    }

    await reloadUsers(api);
  }
}
