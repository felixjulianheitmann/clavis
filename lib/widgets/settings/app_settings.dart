import 'package:clavis/main.dart';
import 'package:clavis/util/logger.dart';
import 'package:clavis/util/preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppSettingsPanel extends StatefulWidget {
  const AppSettingsPanel({super.key});

  @override
  State<AppSettingsPanel> createState() => _AppSettingsPanelState();
}

class _AppSettingsPanelState extends State<AppSettingsPanel> {
  late Future<AppSettings> _settings;

  final _themeSelection = [false, false, false];

  @override
  void initState() {
    super.initState();
    _settings = Preferences.getAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    return FutureBuilder(
      future: _settings,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          log.e(
            "couldn't load app settings and future failed",
            error: snapshot.error,
          );
          return Center(
            child: Card(
              color: Colors.amber,
              child: Text(snapshot.error.toString()),
            ),
          );
        } else if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var settings = snapshot.data!;

        return Stack(
          children: [
            Form(
              child: ListView(
                children: [
                  ListTile(
                    title: Text(translate.settings_theme_select_title),
                    subtitle: Text(translate.settings_theme_select_subtitle),
                    trailing: ToggleButtons(
                      isSelected: [
                        settings.theme == ClavisTheme.light,
                        settings.theme == ClavisTheme.dark,
                        settings.theme == ClavisTheme.black,
                      ],
                      onPressed: (index) {
                        setState(() {
                          for (int i = 0; i < _themeSelection.length; i++) {
                            _themeSelection[i] = i == index;
                          }
                          settings.theme = ClavisTheme.values[index];
                        });
                      },
                      children: [
                        Icon(Icons.light_mode_outlined),
                        Icon(Icons.dark_mode_outlined),
                        Icon(Icons.dark_mode),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: false, // not yet useful
                    child: ListTile(
                      title: Text(translate.settings_autolaunch_title),
                      subtitle: Text(translate.settings_autolaunch_subtitle),
                      trailing: Switch(
                        value: settings.launchOnBoot,
                        onChanged:
                            (b) => setState(() => settings.launchOnBoot = b),
                      ),
                    ),
                  ),

                  // Text("Minimize ?"),
                  Visibility(
                    visible:
                        !kIsWeb, // download directory not useful on web clients
                    child: ListTile(
                      title: Text(translate.settings_download_dir_title),
                      subtitle: Text(
                        settings.downloadDir ??
                            translate.settings_download_dir_not_selected,
                      ),
                      trailing: Icon(Icons.folder),
                      onTap: () async {
                        final dir = await FilePicker.platform.getDirectoryPath(
                          dialogTitle:
                              translate.settings_download_dir_select_title,
                        );
                        setState(() {
                          settings.downloadDir = dir;
                        });
                      },
                    ),
                  ),
                  // download and install
                  // Text("Download bandwidth"),
                  // Text("Extraction auto extract"),
                  // Text("Extraction auto password"),
                  // Text("Mount ISO instead of extraction"),
                  // Text("Auto install portables"),
                  // Text("Auto delete portable games install files"),
                ],
              ),
            ),

            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.all(32),
                child: FloatingActionButton(
                  child: Icon(Icons.save),
                  onPressed: () async {
                    await Preferences.setAppSettings(settings);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
