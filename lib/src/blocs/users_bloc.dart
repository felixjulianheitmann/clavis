import 'package:clavis/src/repositories/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';

sealed class UsersEvent {}

final class Subscribe extends UsersEvent {}

final class Reload extends UsersEvent {
  Reload({required this.api});
  ApiClient api;
}

final class Add extends UsersEvent {
  Add({required this.api, required this.registration});
  ApiClient api;
  RegisterUserDto registration;
}

class UsersState {
  UsersState({this.error, this.stack});
  Object? error;
  StackTrace? stack;
  UsersState copyWith({Object? error, StackTrace? stack}) {
    return UsersState(error: error ?? this.error, stack: stack ?? this.stack);
  }
}

class Unavailable extends UsersState {}

class Ready extends UsersState {
  Ready({required this.users, super.error, super.stack});
  final UserBundles users;
  @override
  Ready copyWith({UserBundles? users, Object? error, StackTrace? stack}) {
    return Ready(
      users: users ?? this.users,
      error: error ?? this.error,
      stack: stack ?? this.stack,
    );
  }
}

class Adding extends Ready {
  Adding({required super.users, super.error, super.stack});
}

class Added extends Ready {
  Added({required super.users, super.error, super.stack});
}

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  UsersBloc(UserRepository userRepo)
    : _userRepo = userRepo,
      super(Unavailable()) {
    on<Subscribe>((event, emit) async {
      await emit.onEach(
        _userRepo.users,
        onData: (users) => emit(Ready(users: users)),
        onError: (error, stackTrace) {
          emit(state.copyWith(error: error, stack: stackTrace));
        },
      );
    });
    on<Reload>((event, emit) => _userRepo.reloadUsers(event.api));
    on<Add>((event, emit) async {
      emit(Adding(users: (state as Ready).users));
      await _userRepo.addUser(event.api, event.registration);
      emit(Added(users: (state as Ready).users));
    });
  }

  final UserRepository _userRepo;

}


