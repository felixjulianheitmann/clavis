import 'package:clavis/src/blocs/auth_bloc.dart';
import 'package:clavis/src/blocs/user_bloc.dart';
import 'package:clavis/src/repositories/error_repository.dart';
import 'package:clavis/src/repositories/user_repository.dart';
import 'package:clavis/src/util/cache_image.dart';
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
    return sizeUnitMapper(sizeBytes, translate)(sizeBytes);
  }

  static String _sizeMapper(
    num value,
    String Function(String) mapper,
    divisor,
  ) {
    return mapper((value / divisor).toStringAsFixed(2));
  }

  static String Function(num) sizeUnitMapper(
    num ref,
    AppLocalizations translate,
  ) {
    if (ref < bytesPerKilo) {
      return (v) => _sizeMapper(v, translate.size_bytes, 1.0);
    } else if (ref < bytesPerMega) {
      return (v) => _sizeMapper(v, translate.size_kilobytes, bytesPerKilo);
    } else if (ref < bytesPerGiga) {
      return (v) => _sizeMapper(v, translate.size_megabytes, bytesPerMega);
    } else if (ref < bytesPerTera) {
      return (v) => _sizeMapper(v, translate.size_gigabytes, bytesPerGiga);
    } else {
      return (v) => _sizeMapper(v, translate.size_terabytes, bytesPerTera);
    }
  }

  static String speedInUnit(num speed, AppLocalizations translate) {
    return speedUnitMapper(speed, translate)(speed);
  }

  static String Function(num) speedUnitMapper(
    num speed,
    AppLocalizations translate,
  ) {
    if (speed < bytesPerKilo) {
      return (v) => _sizeMapper(v, translate.speed_bps, 1.0);
    } else if (speed < bytesPerMega) {
      return (v) => _sizeMapper(v, translate.speed_kbps, bytesPerKilo);
    } else if (speed < bytesPerGiga) {
      return (v) => _sizeMapper(v, translate.speed_mbps, bytesPerMega);
    } else if (speed < bytesPerTera) {
      return (v) => _sizeMapper(v, translate.speed_gbps, bytesPerGiga);
    } else {
      return (v) => _sizeMapper(v, translate.speed_tbps, bytesPerTera);
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
    if (id == null) {
      return UserMeBloc(
        context.read<UserRepository>(),
        context.read<ErrorRepository>(),
      );
    }
    return UserBloc(
      context.read<UserRepository>(),
      context.read<ErrorRepository>(),
      id,
    );
  }

  static String formatDuration(Duration d) {
    final hStr = d.inHours.toString().padLeft(2, '0');
    final mStr = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final sStr = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$hStr:$mStr:$sStr";
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
