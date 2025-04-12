import 'package:clavis/src/repositories/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class UsersEvent {}

final class UsersSubscribe extends UsersEvent {}

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
    on<UsersSubscribe>((event, emit) {
      emit.onEach(
        _userRepo.users,
        onData: (users) => emit(Ready(users: users)),
      );
    });
  }

  final UserRepository _userRepo;

}


