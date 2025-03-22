import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gamevault_web/blocs/credentialBloc.dart';
import 'package:gamevault_web/widgets/auth/page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gamevault_web/widgets/drawer.dart';
import 'package:gamevault_web/widgets/games/page.dart';

class GamevaultHome extends StatefulWidget {
  const GamevaultHome({super.key});
  @override
  State<GamevaultHome> createState() => GamevaultHomeState();
}

class GamevaultHomeState extends State<GamevaultHome> {
  final Future<Credentials?> _credentials = () async {
    final FlutterSecureStorage secureStorage = FlutterSecureStorage();
    String? host = await secureStorage.read(key: 'host');
    String? user = await secureStorage.read(key: 'user');
    String? pass = await secureStorage.read(key: 'pass');
    if (host != null && user != null && pass != null) {
      return Credentials(host: host, user: user, pass: pass);
    }

    return null;
  }();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Credentials?>(
      future: _credentials,
      builder: (context, AsyncSnapshot<Credentials?> snapshot) {
        Widget body = StartupPage();
        if (snapshot.hasData) {
          body = GamesPage();
        } else if (snapshot.hasError) {
          body = StartupPage();
        } else {
          body = StartupPage();
        }

        return Scaffold(
        appBar: snapshot.hasData ? AppBar(title: Text(AppLocalizations.of(context)!.app_title)) : null,
        drawer: SidebarDrawer(),
        body: body,
        );
      }
    );
  }
}

