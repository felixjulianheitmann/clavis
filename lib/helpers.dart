import 'package:flutter/widgets.dart';
import 'package:gamevault_client_sdk/api.dart';

abstract class Helpers {
  static Image cover(GamevaultGame game, double width) {
    final url = game.metadata?.cover?.sourceUrl;
    if (url == null) {
      return Image.asset("Key-Logo_Diagonal.png", width: width);
    }
    return Image.network(url, width: width);
  }
}