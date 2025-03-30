import 'package:flutter/widgets.dart';
import 'package:gamevault_client_sdk/api.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

abstract class Helpers {
  static Image cover(GamevaultGame game, double width) {
    final url = game.metadata?.cover?.sourceUrl;
    if (url == null) {
      return Image.asset("Key-Logo_Diagonal.png", width: width);
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