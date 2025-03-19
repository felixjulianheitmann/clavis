// Openapi Generator last run: : 2025-03-19T20:09:06.527614
import 'package:gamevault_client_sdk/openapi.dart';

class GamevaultApi {
  const GamevaultApi({required this.url});

  final String url;

  Future<String> getGames() async {
    var resp =
        await Openapi(
          basePathOverride: "https://gamevault.bruns-home.org",
        ).getHealthApi().getHealth();
    if (resp.statusCode == 200) {
      return "Success";
    }
    return "None";
  }
}
