import 'package:async/async.dart';
import 'package:clavis/src/repositories/auth_repository.dart';
import 'package:clavis/src/repositories/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';

sealed class UsersEvent {}

final class UsersSubscribe extends UsersEvent {}

class UsersState {}

class Unavailable extends UsersState {}

class Ready extends UsersState {
  Ready({required this.users});
  final List<GamevaultUser> users;
}

class UsersBloc extends Bloc<UsersEvent, UsersState> {
    UsersBloc(UserRepository userRepo, AuthRepository authRepo)
    : _userRepo = userRepo,
      _authRepo = authRepo,
      super(Unavailable()) {
    on<UsersSubscribe>(_onSubscribe);
  }

  final UserRepository _userRepo;
  final AuthRepository _authRepo;

  Future<void> _onSubscribe(UsersSubscribe state, Emitter<UsersState> emit) async {
    final streams = StreamGroup.merge([_authRepo.status, _userRepo.userMe]);
    return emit.onEach(streams, onData: (data) {
      if (data == null) return emit(Unavailable());
      
      if (data is (AuthStatus, ApiClient?)) {
        if (data.$1 != AuthStatus.authenticated) {
          return emit(Unavailable());
        }
      }
      
      if(data is List<GamevaultUser>) {
        return emit(Ready(users: data));
      }

      return emit(Unavailable());
    },);
  }
}


