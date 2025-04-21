import 'package:clavis/src/blocs/auth_bloc.dart';
import 'package:clavis/src/blocs/user_bloc.dart';
import 'package:clavis/src/repositories/user_repository.dart';
import 'package:clavis/src/util/cache_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';
import 'package:clavis/l10n/app_localizations.dart';

abstract class Helpers {
  static const _defaultBannerImage = 'assets/Key-Logo_Diagonal.png';

  static const bytesPerKilo = 1000.0;
  static const bytesPerMega = 1000.0 * bytesPerKilo;
  static const bytesPerGiga = 1000.0 * bytesPerMega;
  static const bytesPerTera = 1000.0 * bytesPerGiga;

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

  static String sizeStrInUnit(String sizeBytes, AppLocalizations translate) {
    try {
      return sizeInUnit(int.parse(sizeBytes), translate);
    } on FormatException {
      return "??";
    }
  }

  static String sizeInUnit(num sizeBytes, AppLocalizations translate) {
    return sizeInUnitUniform([sizeBytes], translate).first;
  }

  static List<String> _sizeMapper(
    List<num> values,
    String Function(String) mapper,
    divider,
  ) {
    return values.map((s) => mapper((s / divider).toStringAsFixed(2))).toList();
  }

  static List<String> sizeInUnitUniform(
    List<num> sizeBytes,
    AppLocalizations translate,
  ) {
    final maxSize = sizeBytes.max;

    if (maxSize < bytesPerKilo) {
      return _sizeMapper(sizeBytes, translate.size_bytes, 1.0);
    } else if (maxSize < bytesPerMega) {
      return _sizeMapper(sizeBytes, translate.size_kilobytes, bytesPerKilo);
    } else if (maxSize < bytesPerGiga) {
      return _sizeMapper(sizeBytes, translate.size_megabytes, bytesPerMega);
    } else if (maxSize < bytesPerTera) {
      return _sizeMapper(sizeBytes, translate.size_gigabytes, bytesPerGiga);
    } else {
      return _sizeMapper(sizeBytes, translate.size_terabytes, bytesPerTera);
    }
  }

  static String speedInUnit(num speed, AppLocalizations translate) {
    if (speed < bytesPerKilo) {
      return _sizeMapper([speed], translate.speed_bps, 1.0).first;
    } else if (speed < bytesPerMega) {
      return _sizeMapper([speed], translate.speed_kbps, bytesPerKilo).first;
    } else if (speed < bytesPerGiga) {
      return _sizeMapper([speed], translate.speed_mbps, bytesPerMega).first;
    } else if (speed < bytesPerTera) {
      return _sizeMapper([speed], translate.speed_gbps, bytesPerGiga).first;
    } else {
      return _sizeMapper([speed], translate.speed_tbps, bytesPerTera).first;
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
