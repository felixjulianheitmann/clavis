import 'package:clavis/src/repositories/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';

sealed class UsersEvent {}

final class Subscribe extends UsersEvent {}

final class Reload extends UsersEvent {
  Reload({required this.api});
  ApiClient api;
}

class UsersState {}

class Unavailable extends UsersState {}

class Ready extends UsersState {
  Ready({required this.users});
  final UserBundles users;
}

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  UsersBloc(UserRepository userRepo)
    : _userRepo = userRepo,
      super(Unavailable()) {
    on<Subscribe>((event, emit) async {
      await emit.onEach(
        _userRepo.users,
        onData: (users) => emit(Ready(users: users)),
      );
    });
    on<Reload>((event, emit) => _userRepo.reloadUsers(event.api));
  }

  final UserRepository _userRepo;

}


