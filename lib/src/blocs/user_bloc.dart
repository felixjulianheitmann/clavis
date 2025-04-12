import 'package:clavis/src/repositories/user_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';

sealed class UserEvent {}

final class Subscribe extends UserEvent {}

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
  Edited({this.username, this.firstName, this.lastName, this.email});
  String? username;
  String? firstName;
  String? lastName;
  String? email;
}

class UserState {}

class Unavailable extends UserState {}

class Ready extends UserState {
  Ready({required this.user});
  final UserBundle user;
}

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc(UserRepository userRepo, this.id)
    : _userRepo = userRepo,
      super(Unavailable()) {
    on<Subscribe>((_, emit) {
      emit.onEach(
        _userRepo.user(id),
        onData: (user) => emit(Ready(user: user)),
      );
    });
    on<Delete>((event, emit) => _userRepo.deleteUser(event.api, id));
    on<Deactivate>((event, emit) => _userRepo.deactivateUser(event.api, id));
    on<UploadAvatar>((event, emit) => _userRepo.uploadAvatar(event.api, id, event.fileStream, event.file));
  }

  final UserRepository _userRepo;
  final num id;
}

class UserMeBloc extends Bloc<UserEvent, UserState> {
  UserMeBloc(UserRepository userRepo)
    : _userRepo = userRepo,
      super(Unavailable()) {
    on<Subscribe>((_, emit) {
      emit.onEach(_userRepo.userMe, onData: (user) => emit(Ready(user: user)));
    });
  }

  final UserRepository _userRepo;
}
