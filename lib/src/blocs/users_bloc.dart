import 'package:clavis/src/repositories/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';

sealed class UsersEvent {}

final class UsersSubscribe extends UsersEvent {}

final class UsersReload extends UsersEvent {
  UsersReload({required this.api});
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

class UsersUnavailable extends UsersState {}

class UsersReady extends UsersState {
  UsersReady({required this.users, super.error, super.stack});
  final UserBundles users;
  @override
  UsersReady copyWith({UserBundles? users, Object? error, StackTrace? stack}) {
    return UsersReady(
      users: users ?? this.users,
      error: error ?? this.error,
      stack: stack ?? this.stack,
    );
  }
}

class UsersAdding extends UsersReady {
  UsersAdding({required super.users, super.error, super.stack});
}

class UsersAdded extends UsersReady {
  UsersAdded({required super.users, super.error, super.stack});
}

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  UsersBloc(UserRepository userRepo)
    : _userRepo = userRepo,
      super(UsersUnavailable()) {
    on<UsersSubscribe>((event, emit) async {
      await emit.onEach(
        _userRepo.users,
        onData: (users) => emit(UsersReady(users: users)),
        onError: (error, stackTrace) {
          emit(state.copyWith(error: error, stack: stackTrace));
        },
      );
    });
    on<UsersReload>((event, emit) => _userRepo.reloadUsers(event.api));
    on<Add>((event, emit) async {
      emit(UsersAdding(users: (state as UsersReady).users));
      await _userRepo.addUser(event.api, event.registration);
      emit(UsersAdded(users: (state as UsersReady).users));
    });
  }

  final UserRepository _userRepo;

}


