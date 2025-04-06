import 'package:clavis/util/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';

class UsersState {
  UsersState({this.users = const [], this.api});
  List<GamevaultUser> users;
  ApiClient? api;
  bool get hasApi => api != null;
  bool get isInitialized => hasApi; // is actually the same at the moment
}

class UsersEvent {}

class UsersInitializedEvent extends UsersEvent {
  UsersInitializedEvent({required this.api, required this.users});
  List<GamevaultUser> users;
  ApiClient api;
}

class UsersChangedEvent extends UsersEvent {}

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  UsersBloc({required List<GamevaultUser> users, required ApiClient api})
    : super(UsersState(users: users, api: api)) {
    /**
     * on initial user load
     */
    on<UsersInitializedEvent>(
      (event, emit) => emit(UsersState(users: event.users, api: event.api)),
    );

    on<UsersChangedEvent>((event, emit) async {
      // do nothing if you can't  do anything
      if (!state.hasApi) return;

      try {
        final result = await UserApi(state.api).getUsers();
        if (result == null) {
          log.e("users query returned empty response");
          return;
        }
        emit(UsersState(api: state.api, users: result));
      } catch (e) {
        log.e("couldn't query users", error: e);
        return;
      }
    });
  }
}
