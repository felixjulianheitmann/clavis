
import 'package:clavis/util/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';

class UserState {
  UserState(this._user);
  final GamevaultUser? _user;
  GamevaultUser? get user => _user;
}

class UserReadyState extends UserState {
  UserReadyState(GamevaultUser super._user);

  @override
  GamevaultUser get user => _user!;
}

class UserUpdatingState extends UserState {
  UserUpdatingState(GamevaultUser super._user);

  @override
  GamevaultUser get user => _user!;
}

class UserUpdateFailedState extends UserState {
  UserUpdateFailedState(GamevaultUser super._user, {required this.error});
  Object error;

  @override
  GamevaultUser get user => _user!;
}

class UserDeletedState extends UserState {
  UserDeletedState() : super(null);
}

class UserEvent {}

class UserChangedEvent extends UserEvent {
  UserChangedEvent({
    required this.user,
    required this.update,
    required this.api,
  });
  final GamevaultUser user;
  final UpdateUserDto update;
  final ApiClient api;
}

class UserDeletedEvent extends UserEvent {
  UserDeletedEvent({required this.user, required this.api});
  final GamevaultUser user;
  final ApiClient api;
}

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc({required GamevaultUser initialUser})
    : super(UserReadyState(initialUser)) {
    on<UserDeletedEvent>((event, emit) async {
      emit(UserUpdatingState(state.user!));

      try {
        final result = await UserApi(
          event.api,
        ).deleteUserByUserId(event.user.id);
        if (result == null) {
          final msg = "delete user returned with null - user-id: ${event.user.id}";
          log.e(msg);
          emit(UserUpdateFailedState(event.user, error: msg));
        }
      } catch (e) {
        log.e("delete user failed: ${event.user.id}", error: e);
        emit(UserUpdateFailedState(event.user, error: e));
        return;
      }

      emit(UserDeletedState());
    });
    on<UserChangedEvent>((event, emit) async {
      emit(UserUpdatingState(event.user));

      // update user using API
      try {
        final result = await UserApi(
          event.api,
        ).putUserByUserId(event.user.id, event.update);

        if (result == null) {
          Object error =
              "user update returned with null user - user-id: ${event.user.id}";
          log.e(error);
          emit(UserUpdateFailedState(event.user, error: error));
          return;
        }

        emit(UserReadyState(result));
      } catch (e) {
        log.e("user update failed", error: e);
        emit(UserUpdateFailedState(event.user, error: e));
        return;
      }
    });
  }
}
