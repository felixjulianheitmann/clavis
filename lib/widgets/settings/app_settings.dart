import 'package:clavis/blocs/settings_bloc.dart';
import 'package:clavis/main.dart';
import 'package:clavis/util/logger.dart';
import 'package:clavis/util/preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppSettingsPanel extends StatelessWidget {
  const AppSettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state is SettingsLoadingState) {
          return Center(child: CircularProgressIndicator());
        }

        var settings = (state as SettingsLoadedState).settings;

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
                          context.read<SettingsBloc>().add(SettingsChangedEvent(settings: settings.with(theme: ClavisTheme.values[index])))
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
                            (b) {
                          context.read<SettingsBloc>().add(SettingsChangedEvent(settings: settings.with(launchOnBoot: b)));
                            },
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
                        if(context.mounted) {
                          context.read<SettingsBloc>().add(SettingsChangedEvent(settings: settings.with(dir)));
                        }
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
