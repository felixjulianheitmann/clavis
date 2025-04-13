import 'package:clavis/src/repositories/user_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';

sealed class UserEvent {}

final class Subscribe extends UserEvent {}

final class Reload extends UserEvent {
  Reload({required this.api});
  final ApiClient api;
}

final class Delete extends UserEvent {
  Delete({required this.api});
  final ApiClient api;
}

final class Restore extends UserEvent {
  Restore({required this.api});
  final ApiClient api;
}

final class Activate extends UserEvent {
  Activate({required this.api});
  final ApiClient api;
}

final class Deactivate extends UserEvent {
  Deactivate({required this.api});
  final ApiClient api;
}

final class UploadAvatar extends UserEvent {
  UploadAvatar({
    required this.api,
    required this.fileStream,
    required this.file,
  });
  final ApiClient api;
  final Stream<List<int>> fileStream;
  final PlatformFile file;
}

final class Edited extends UserEvent {
  Edited({
    required this.api,
    this.username,
    this.firstName,
    this.lastName,
    this.email,
  });
  ApiClient api;
  String? username;
  String? firstName;
  String? lastName;
  String? email;
}

class UserState {
  UserState({this.error, this.stack});
  Object? error;
  StackTrace? stack;
  UserState copyWith({Object? error, StackTrace? stack}) {
    return UserState(error: error ?? this.error, stack: stack ?? this.stack);
  }
}

class Unavailable extends UserState {}

class Ready extends UserState {
  Ready({required this.user, super.error, super.stack});
  final UserBundle user;
  @override
  Ready copyWith({UserBundle? user, Object? error, StackTrace? stack}) {
    return Ready(
      user: user ?? this.user,
      error: error ?? this.error,
      stack: stack ?? this.stack,
    );
  }
}

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepo;
  final num? id;

  UserBloc(UserRepository userRepo, this.id)
    : _userRepo = userRepo,
      super(Unavailable()) {
    on<Subscribe>((_, emit) async {
      final stream = id == null ? _userRepo.userMe : _userRepo.user(id!);
      await emit.onEach(
        stream,
        onData: (user) => emit(Ready(user: user)),
        onError: (error, stackTrace) {
          emit(state.copyWith(error: error, stack: stackTrace));
        },
      );
    });
    on<Reload>((e, _) {
      if (id != null) {
        _userRepo.getUser(e.api, id!);
      } else {
        _userRepo.getUserMe(e.api);
      }
    });
    on<Delete>((e, _) {
      if (id != null) {
        _userRepo.deleteUser(e.api, id!);
      } else {
        _userRepo.deleteUserMe(e.api);
      }
    });
    on<Restore>((e, _) {
      if (id != null) _userRepo.restoreUser(e.api, id!);
    });
    on<Activate>((e, _) {
      if (id != null) _userRepo.activateUser(e.api, id!);
    });
    on<Deactivate>((e, _) {
      if (id != null) {
        _userRepo.deactivateUser(e.api, id!);
      } else {
        _userRepo.deactivateUserMe(e.api);
      }
    });
    on<UploadAvatar>((e, _) async {
      final mediaId = await _userRepo.uploadAvatar(e.api, e.fileStream, e.file);
      if (mediaId != null) {
        final userUpdate = UpdateUserDto(avatarId: mediaId);
        if (id != null) {
          await _userRepo.updateUser(e.api, id!, userUpdate);
        } else {
          await _userRepo.updateUserMe(e.api, userUpdate);
        }
      }
    });
    on<Edited>((e, _) {
      final update = UpdateUserDto(
        username: e.username,
        firstName: e.firstName,
        lastName: e.lastName,
        email: e.email,
      );
      if (id != null) {
        _userRepo.updateUser(e.api, id!, update);
      } else {
        _userRepo.updateUserMe(e.api, update);
      }
    });
  }
}

// a different type makes the bloc lookup a lot easier
class UserMeBloc extends UserBloc {
  UserMeBloc(UserRepository userRepo) : super(userRepo, null);
}
