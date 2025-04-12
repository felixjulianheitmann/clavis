import 'package:flutter/material.dart';
import 'package:gamevault_client_sdk/api.dart';
import 'package:clavis/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

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
          Text(game.title ?? path.basenameWithoutExtension(game.filePath)),
        ],
      );
    }
    return Image.network(url, width: width);
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
}
