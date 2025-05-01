import 'dart:async';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gamevault_client_sdk/api.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';

class UserRepoException implements Exception {
  UserRepoException(this.msg);
  final String msg;
  @override
  String toString() => 'UserRepoException: $msg';
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
      await for (final u in _userMeController.stream) {
        _userMe = u;
      }
    });
    Future(() async {
      await for (final ul in _usersController.stream) {
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

    await for (final users in _usersController.stream) {
      final user = users.firstWhereOrNull((u) => u.user.id == id);
      if (user != null) yield user;
    }
  }

  Future<void> reloadUsers(ApiClient api) async {
    final users = await UserApi(api).getUsers();
    if (users == null) {
      throw UserRepoException("users reload returned with null");
    }

    for(final u in users) {
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
    final me = await UserApi(api).getUsersMe();
    if (me == null) {
      throw UserRepoException("user me query returned with null");
    }

    getAvatar(api, me);
    _userMeController.add(UserBundle(user: me));
  }

  Future<void> getUser(ApiClient api, num id) async {
    GamevaultUser? user;
    try {
      user = await UserApi(api).getUserByUserId(id);
    } catch (e) {
      throw UserRepoException("Couldn't query user info: $e");
    }
    if (user == null) {
      throw UserRepoException("user query returned with null: $id");
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
    } catch (e) {
      throw UserRepoException("error querying user avatar: $e");
    }
    if (media == null) {
      throw UserRepoException(
        "avatar query returned null response - user-id: ${user.id}",
      );
    }

    onAvatar(MemoryImage(Uint8List.fromList(media.codeUnits)));
  }

  Future<void> updateUserMe(ApiClient api, UpdateUserDto update) async {
    final updatedMe = await UserApi(api).putUsersMe(update);
    if (updatedMe == null) {
      throw UserRepoException("user me update returned with null");
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
      throw UserRepoException("Couldn't update user info: $e");
    }

    if (updatedUser == null) {
      throw UserRepoException("user update returned with null");
    }

    // username has been updated and will be needed for authentication
    if (update.username != null) {
      (api.authentication as HttpBasicAuth).username = update.username!;
    }
    if (update.password != null) {
      (api.authentication as HttpBasicAuth).password = update.password!;
    }
    await getUser(api, id); // reload user list
  }

  Future<void> deleteUser(ApiClient api, num id) async {
    GamevaultUser? res;
    try {
      res = await UserApi(api).deleteUserByUserId(id);
    } catch (e) {
      throw UserRepoException("error deleting user: $e");
    }
    if (res == null) {
      throw UserRepoException(
        "user deletion returned null response - user-id: $id",
      );
    }

    await reloadUsers(api);
  }
  Future<void> deleteUserMe(ApiClient api) async {
    GamevaultUser? res;
    try {
      res = await UserApi(api).deleteUserMe();
    } catch (e) {
      throw UserRepoException("error deleting user me: $e");
    }
    if (res == null) {
      throw UserRepoException("user me deletion returned null response");
    }

    await reloadUsers(api);
  }

  Future<void> restoreUser(ApiClient api, num id) async {
    GamevaultUser? res;
    try {
      res = await UserApi(api).postUserRecoverByUserId(id);
    } catch (e) {
      throw UserRepoException("error restoring user: $e");
    }
    if (res == null) {
      throw UserRepoException(
        "user restoration returned null response - user-id: $id",
      );
    }

    await reloadUsers(api);
  }

  Future<void> addBookmark(ApiClient api, num id) async {
    try {
      await UserApi(api).postUsersMeBookmark(id);
    } catch (e) {
      throw UserRepoException("error adding bookmark: $id - $e");
    }
    await getUserMe(api);
  }

  Future<void> removeBookmark(ApiClient api, num id) async {
    try {
      await UserApi(api).deleteUsersMeBookmark(id);
    } catch (e) {
      throw UserRepoException("error adding bookmark: $id - $e");
    }
    await getUserMe(api);
  }

  Future<void> activateUser(ApiClient api, num id) async {
    final update = UpdateUserDto(activated: true);
    await updateUser(api, id, update);
  }

  Future<void> deactivateUser(ApiClient api, num id) async {
    final update = UpdateUserDto(activated: false);
    await updateUser(api, id, update);
  }

  Future<void> deactivateUserMe(ApiClient api) async {
    final update = UpdateUserDto(activated: false);
    await updateUserMe(api, update);
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
    } catch (e) {
      throw UserRepoException("upload of avatar failed: $e");
    }

    if (uploaded == null) {
      throw UserRepoException(
        "upload of avatar returned with null",
      );
    }

    return uploaded.id;
  }

  Future<void> addUser(ApiClient api, RegisterUserDto registration) async {
    GamevaultUser? addedUser;
    try {
      addedUser = await UserApi(api).postUserRegister(registration);
    } catch (e) {
      _usersController.addError(
        UserRepoException("user registration failed: $e"),
      );
    }
    if (addedUser == null) {
      _usersController.addError(
        UserRepoException("user registration returned with null"),
      );
    }

    await reloadUsers(api);
  }
}
