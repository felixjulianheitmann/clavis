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

final class Deactivate extends UserEvent {
  Deactivate({required this.api});
  final ApiClient api;
}

final class UploadAvatar extends UserEvent {
  UploadAvatar({required this.api, required this.fileStream, required this.file});
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
    return UserState(
      error: error ?? this.error,
      stack: stack ?? this.stack,
    );
  }
}

class Unavailable extends UserState {}

class Ready extends UserState {
  Ready({required this.user, super.error, super.stack});
  final UserBundle user;
  @override
  Ready copyWith({UserBundle? user,  Object? error, StackTrace? stack}) {
    return Ready(user: user ?? this.user, error: error ?? this.error, stack: stack ?? this.stack);
  }
}

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc(UserRepository userRepo, this.id)
    : _userRepo = userRepo,
      super(Unavailable()) {
    on<Subscribe>((_, emit) async {
      await emit.onEach(
        _userRepo.user(id),
        onData: (user) => emit(Ready(user: user)),
        onError: (error, stackTrace) {
          emit(state.copyWith(error: error, stack: stackTrace));
        },
      );
    });
    on<Reload>((e, _) => _userRepo.getUser(e.api, id));
    on<Delete>((e, _) => _userRepo.deleteUser(e.api, id));
    on<Deactivate>((e, _) => _userRepo.deactivateUser(e.api, id));
    on<UploadAvatar>(
      (e, _) => _userRepo.uploadAvatar(e.api, id, e.fileStream, e.file),
    );
    on<Edited>((e, _) {
      final update = UpdateUserDto(
        username: e.username,
        firstName: e.firstName,
        lastName: e.lastName,
        email: e.email,
      );
      _userRepo.updateUser(e.api, id, update);
    });
  }

  final UserRepository _userRepo;
  final num id;
}

class UserMeBloc extends Bloc<UserEvent, UserState> {
  UserMeBloc(UserRepository userRepo)
    : _userRepo = userRepo,
      super(Unavailable()) {
    on<Subscribe>((_, emit) async {
      await emit.onEach(
        _userRepo.userMe,
        onData: (user) => emit(Ready(user: user)),
      );
    });
    on<Reload>((event, emit) => _userRepo.getUserMe(event.api));
  }

  final UserRepository _userRepo;
}
