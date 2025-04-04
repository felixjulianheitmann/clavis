import 'package:clavis/blocs/settings_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clavis/l10n/app_localizations.dart';

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
        return ListView(
          children: [
            ListTile(
              title: Text(translate.settings_theme_select_title),
              subtitle: Text(translate.settings_theme_select_subtitle),
              trailing: ToggleButtons(
                isSelected:
                    ThemeMode.values.map((t) => t == settings.theme).toList(),
                onPressed: (index) {
                  context.read<SettingsBloc>().add(
                    SettingsChangedEvent(
                      settings: settings.copy(theme: ThemeMode.values[index]),
                    ),
                  );
                },
                children: [
                  Tooltip(
                    message: translate.settings_theme_tooltip_system,
                    child: Icon(Icons.computer),
                  ),
                  Tooltip(
                    message: translate.settings_theme_tooltip_light,
                    child: Icon(Icons.light_mode_outlined),
                  ),
                  Tooltip(
                    message: translate.settings_theme_tooltip_dark,
                    child: Icon(Icons.dark_mode_outlined),
                  ),
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
                  onChanged: (b) {
                    context.read<SettingsBloc>().add(
                      SettingsChangedEvent(
                        settings: settings.copy(launchOnBoot: b),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Text("Minimize ?"),
            Visibility(
              visible: !kIsWeb, // download directory not useful on web clients
              child: ListTile(
                title: Text(translate.settings_download_dir_title),
                subtitle: Text(
                  settings.downloadDir ??
                      translate.settings_download_dir_not_selected,
                ),
                trailing: Icon(Icons.folder),
                onTap: () async {
                  final dir = await FilePicker.platform.getDirectoryPath(
                    dialogTitle: translate.settings_download_dir_select_title,
                  );
                  if (context.mounted) {
                    context.read<SettingsBloc>().add(
                      SettingsChangedEvent(
                        settings: settings.copy(downloadDir: dir),
                      ),
                    );
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
        );
      },
    );
  }
}
