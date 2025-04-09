import 'package:clavis/src/repositories/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';

sealed class UserMeEvent {}

final class Subscribe extends UserMeEvent {}

class UserMeState {}

class Unavailable extends UserMeState {}

class Ready extends UserMeState {
  Ready({required this.me});
  final GamevaultUser me;
}

class UserMeBloc extends Bloc<UserMeEvent, UserMeState> {
  UserMeBloc(UserRepository userRepo) : _userRepo = userRepo, super(Unavailable()) {
    on<Subscribe>(_onSubscribe);
  }

  final UserRepository _userRepo;

  Future<void> _onSubscribe(Subscribe state, Emitter<UserMeState> emit) async {
    return emit.onEach(_userRepo.userMe, onData: (me) {
      if(me == null) return emit(Unavailable());
      
      return emit(Ready(me: me));
    },);
  }
}


