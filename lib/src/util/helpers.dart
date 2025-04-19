import 'package:clavis/src/blocs/auth_bloc.dart';
import 'package:clavis/src/blocs/user_bloc.dart';
import 'package:clavis/src/repositories/user_repository.dart';
import 'package:clavis/src/util/cache_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';
import 'package:clavis/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

abstract class Helpers {
  static const _defaultBannerImage = 'assets/Key-Logo_Diagonal.png';

  static Widget avatar(ImageProvider? avatar, {double? radius}) {
    final standardIcon = CircleAvatar(
      radius: radius,
      child: Icon(Icons.person, size: radius),
    );
    if (avatar == null) return standardIcon;

    return CircleAvatar(backgroundImage: avatar, radius: radius);
  }

  static String userTitle(GamevaultUser user) {
    if (user.firstName == null && user.lastName == null) {
      return user.username;
    } else if (user.lastName == null) {
      return user.firstName!;
    } else if (user.firstName == null) {
      return user.lastName!;
    } else {
      return "${user.firstName} ${user.lastName}";
    }
  }

  static Widget cover(GamevaultGame game, double width) {
    final url = game.metadata?.cover?.sourceUrl;
    if (url == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(_defaultBannerImage, fit: BoxFit.cover),
          Text(game.title ?? game.toString()),
        ],
      );
    }
    return CacheImage(imageUrl: url, width: width);
  }

  static String sizeInUnit(String sizeBytes, AppLocalizations translate) {
    const bytesPerKilo = 1000.0;
    const bytesPerMega = 1000.0 * bytesPerKilo;
    const bytesPerGiga = 1000.0 * bytesPerMega;
    const bytesPerTera = 1000.0 * bytesPerGiga;
    int size;
    try {
      size = int.parse(sizeBytes);
    } on FormatException {
      return "??";
    }

    final f = NumberFormat(".##");

    if (size < bytesPerKilo) {
      return translate.size_bytes(f.format(size));
    } else if (size < bytesPerMega) {
      return translate.size_kilobytes(f.format(size / bytesPerKilo));
    } else if (size < bytesPerGiga) {
      return translate.size_megabytes(f.format(size / bytesPerMega));
    } else if (size < bytesPerTera) {
      return translate.size_gigabytes(f.format(size / bytesPerGiga));
    } else {
      return translate.size_terabytes(f.format(size / bytesPerTera));
    }
  }

  static ApiClient? getApi(BuildContext context) {
    return context.select((AuthBloc a) {
      if (a.state is Authenticated) {
        return (a.state as Authenticated).api;
      }
      return null;
    });
  }

  static UserBundle? getMe(BuildContext context) {
    return context.select((UserMeBloc u) {
      if (u.state is Ready) {
        return (u.state as Ready).user;
      }
      return null;
    });
  }

  static Bloc getUserSpecificBloc(BuildContext context, num? id) {
    if (id == null) return UserMeBloc(context.read<UserRepository>());
    return UserBloc(context.read<UserRepository>(), id);
  }
}

class UserSpecificBlocBuilder extends StatelessWidget {
  const UserSpecificBlocBuilder({
    super.key,
    required this.id,
    required this.builder,
  });
  final num? id;
  final Widget Function(BuildContext context, UserState state) builder;

  @override
  Widget build(BuildContext context) {
    if (id == null) {
      return BlocBuilder<UserMeBloc, UserState>(builder: builder);
    } else {
      return BlocBuilder<UserBloc, UserState>(builder: builder);
    }
  }
}

class UserSpecificBlocListener extends StatelessWidget {
  const UserSpecificBlocListener({
    super.key,
    required this.id,
    required this.listener,
    required this.child,
  });
  final num? id;
  final void Function(BuildContext context, UserState state) listener;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (id == null) {
      return BlocListener<UserMeBloc, UserState>(
        listener: listener,
        child: child,
      );
    } else {
      return BlocListener<UserBloc, UserState>(
        listener: listener,
        child: child,
      );
    }
  }
}
