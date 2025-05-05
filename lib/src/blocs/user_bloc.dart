import 'package:clavis/l10n/app_localizations.dart';
import 'package:clavis/src/repositories/error_repository.dart';
import 'package:clavis/src/repositories/user_repository.dart';
import 'package:clavis/src/types.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';

class _UserErrCode extends ClavisErrCode {
  @override
  String localize(AppLocalizations translate) => translate.error_user_api;
}

sealed class UserEvent {}

final class UserSubscribe extends UserEvent {}

final class UserReload extends UserEvent {
  UserReload({required this.api});
  final ApiClient api;
}

final class Delete extends UserEvent {
  Delete({required this.api});
  final ApiClient api;
}

final class Restore extends UserEvent {
  Restore({required this.api});
  final ApiClient api;
}

final class Activate extends UserEvent {
  Activate({required this.api});
  final ApiClient api;
}

final class Deactivate extends UserEvent {
  Deactivate({required this.api});
  final ApiClient api;
}

final class AddBookmark extends UserEvent {
  AddBookmark({required this.api, required this.game});
  final ApiClient api;
  final GamevaultGame game;
}

final class RemoveBookmark extends UserEvent {
  RemoveBookmark({required this.api, required this.game});
  final ApiClient api;
  final GamevaultGame game;
}

final class UploadAvatar extends UserEvent {
  UploadAvatar({
    required this.api,
    required this.fileStream,
    required this.file,
  });
  final ApiClient api;
  final Stream<List<int>> fileStream;
  final PlatformFile file;
}

final class Edited extends UserEvent {
  Edited({
    required this.api,
    this.username,
    this.firstName,
    this.lastName,
    this.email,
  });
  ApiClient api;
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

class UserBaseBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepo;
  final ErrorRepository _errorRepo;
  final num? id;

  UserBaseBloc(UserRepository userRepo, ErrorRepository errorRepo, this.id)
    : _userRepo = userRepo,
      _errorRepo = errorRepo,
      super(Unavailable()) {
    on<UserSubscribe>((_, emit) async {
      final stream = id == null ? _userRepo.userMe : _userRepo.user(id!);
      await emit.onEach(
        stream,
        onData: (user) => emit(Ready(user: user)),
        onError: (error, stackTrace) {
          if (error is ClavisException) {
            _errorRepo.setError(ClavisError(_UserErrCode(), error));
          }
        },
      );
    });
    on<UserReload>((e, emit) {
      emit(Unavailable());
      if (id != null) {
        _userRepo.getUser(e.api, id!);
      } else {
        _userRepo.getUserMe(e.api);
      }
    });
    on<Delete>((e, _) {
      if (id != null) {
        _userRepo.deleteUser(e.api, id!);
      } else {
        _userRepo.deleteUserMe(e.api);
      }
    });
    on<Restore>((e, _) {
      if (id != null) _userRepo.restoreUser(e.api, id!);
    });
    on<Activate>((e, _) {
      if (id != null) _userRepo.activateUser(e.api, id!);
    });
    on<Deactivate>((e, _) {
      if (id != null) {
        _userRepo.deactivateUser(e.api, id!);
      } else {
        _userRepo.deactivateUserMe(e.api);
      }
    });
    on<UploadAvatar>((e, _) async {
      final mediaId = await _userRepo.uploadAvatar(e.api, e.fileStream, e.file);
      if (mediaId != null) {
        final userUpdate = UpdateUserDto(avatarId: mediaId);
        if (id != null) {
          await _userRepo.updateUser(e.api, id!, userUpdate);
        } else {
          await _userRepo.updateUserMe(e.api, userUpdate);
        }
      }
    });
    on<Edited>((e, _) {
      final update = UpdateUserDto(
        username: e.username,
        firstName: e.firstName,
        lastName: e.lastName,
        email: e.email,
      );
      if (id != null) {
        _userRepo.updateUser(e.api, id!, update);
      } else {
        _userRepo.updateUserMe(e.api, update);
      }
    });
    on<AddBookmark>((e, _) => _userRepo.addBookmark(e.api, e.game.id));
    on<RemoveBookmark>((e, _) => _userRepo.removeBookmark(e.api, e.game.id));
  }
}

// a different type makes the bloc lookup a lot easier
class UserMeBloc extends UserBaseBloc {
  UserMeBloc(UserRepository userRepo, ErrorRepository errorRepo)
    : super(userRepo, errorRepo, null);
}
class UserBloc extends UserBaseBloc {
  UserBloc(super.userRepo, super.errorRepo, super.id);
}
