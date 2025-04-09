import 'dart:async';

import 'package:clavis/util/logger.dart';
import 'package:gamevault_client_sdk/api.dart';

class UserRepository {
  final _userMeController = StreamController<GamevaultUser?>();
  final _usersController = StreamController<List<GamevaultUser>?>();

  Stream<GamevaultUser?> get userMe async* {
    yield* _userMeController.stream;
  }
  Stream<List<GamevaultUser>?> get users async* {
    yield* _usersController.stream;
  }

  Future<void> reloadUsers(ApiClient api) async {
    final users = await UserApi(api).getUsers();
    if(users == null) {
      throw Exception("users reload returned with null");
    }
    _usersController.add(users);
  }


  Future<void> getUserMe(ApiClient api) async {
    final me = await UserApi(api).getUsersMe();
    if(me == null) {
      throw Exception("user me query returned with null");
    }
    _userMeController.add(me);
  }

  Future<GamevaultUser?> getUser(ApiClient api, int id) async {
    try {
      final user = await UserApi(api).getUserByUserId(id);
      return user;
    } catch (e) {
      log.e("Couldn't query user info", error: e);
    }

    return null;
  }

  Future<void> updateUserMe(ApiClient api, UpdateUserDto update) async {
    final updatedMe = await UserApi(api).putUsersMe(update);
    if(updatedMe == null) {
      throw Exception("user me update returned with null");
    }

    _userMeController.add(updatedMe);
  }

  Future<GamevaultUser?> updateUser(ApiClient api, int id, UpdateUserDto update) async {
    try {
      final updatedUser = await UserApi(api).putUserByUserId(id, update);
      if(updatedUser != null) await reloadUsers(api); // reload user list
      return updatedUser;
    } catch (e) {
      log.e("Couldn't update user info", error: e);
    }

    return null;
  }

}
