import 'package:async/async.dart';
import 'package:clavis/src/repositories/auth_repository.dart';
import 'package:clavis/src/repositories/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';

sealed class UserMeEvent {}

final class UserMeSubscribe extends UserMeEvent {}

class UserMeState {}

class Unavailable extends UserMeState {}

class Ready extends UserMeState {
  Ready({required this.me});
  final GamevaultUser me;
}

class UserMeBloc extends Bloc<UserMeEvent, UserMeState> {
  UserMeBloc(UserRepository userRepo, AuthRepository authRepo)
    : _userRepo = userRepo,
      _authRepo = authRepo,
      super(Unavailable()) {
    on<UserMeSubscribe>(_onSubscribe);
  }

  final UserRepository _userRepo;
  final AuthRepository _authRepo;

  Future<void> _onSubscribe(
    UserMeSubscribe state,
    Emitter<UserMeState> emit,
  ) async {
    final streams = StreamGroup.merge([_authRepo.status, _userRepo.userMe]);
    emit.onEach(
      streams,
      onData: (data) {
        if (data == null) return emit(Unavailable());

        if (data is (AuthStatus, ApiClient?)) {
          if (data.$1 != AuthStatus.authenticated) {
            return emit(Unavailable());
          }
        }
        if (data is GamevaultUser) {
          return emit(Ready(me: data));
        }

        return emit(Unavailable());
      },
    );

    emit.onEach(_userRepo.userMe, onData: (me) {
    },);
  }
}


