import 'package:clavis/src/blocs/pref_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clavis/l10n/app_localizations.dart';

class AppSettingsPanel extends StatelessWidget {
  const AppSettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final prefsReady = context.select(
      (PrefBloc p) => p.state.status == Status.ready,
    );
    if (!prefsReady) return Center(child: CircularProgressIndicator());

    return ListView(
      children: [
        _ThemeTile(),
        _AutoLaunchTile(),
        _DownloadDirTile(),
        // download and install
        // Text("Download bandwidth"),
        // Text("Extraction auto extract"),
        // Text("Extraction auto password"),
        // Text("Mount ISO instead of extraction"),
        // Text("Auto install portables"),
        // Text("Auto delete portable games install files"),
      ],
    );
  }
}

class _DownloadDirTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final downloadDir = context.select(
      (PrefBloc p) => p.state.prefs.downloadDir,
    );

    final translate = AppLocalizations.of(context)!;

    final tile = ListTile(
      title: Text(translate.settings_download_dir_title),
      subtitle: Text(
        downloadDir ?? translate.settings_download_dir_not_selected,
      ),
      trailing: Icon(Icons.folder),
      onTap: () async {
        final dir = await FilePicker.platform.getDirectoryPath(
          dialogTitle: translate.settings_download_dir_select_title,
        );
        if (dir != null && context.mounted) {
          context.read<PrefBloc>().add(SetDownloadDir(downloadDir: dir));
        }
      },
    );

    return Visibility(
      visible: !kIsWeb, // download directory not useful on web clients
      child: tile,
    );
  }
}

class _AutoLaunchTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final launchOnBoot = context.select((PrefBloc p) => p.state.prefs.launchOnBoot);
    final translate = AppLocalizations.of(context)!;

    return Visibility(
      visible: false, // not yet useful
      child: ListTile(
        title: Text(translate.settings_autolaunch_title),
        subtitle: Text(translate.settings_autolaunch_subtitle),
        trailing: Switch(
          value: launchOnBoot,
          onChanged: (b) {
            context.read<PrefBloc>().add(
              SetLaunchOnBoot(launchOnBoot: b),
            );
          },
        ),
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = context.select((PrefBloc p) => p.state.prefs.theme);
    final translate = AppLocalizations.of(context)!;

    final themeOptions = <Tooltip>[
      Tooltip(
        message: translate.settings_theme_tooltip_system,
        child: Icon(Icons.computer),
      ),
      Tooltip(
        message: translate.settings_theme_tooltip_light,
        child: Icon(Icons.light_mode),
      ),
      Tooltip(
        message: translate.settings_theme_tooltip_dark,
        child: Icon(Icons.dark_mode),
      ),
    ];

    return ListTile(
      title: Text(translate.settings_theme_select_title),
      subtitle: Text(translate.settings_theme_select_subtitle),
      trailing: ToggleButtons(
        isSelected: ThemeMode.values.map((t) => t == theme).toList(),
        onPressed: (index) {
          context.read<PrefBloc>().add(
            SetTheme(theme: ThemeMode.values[index]),
          );
        },
        children: themeOptions,
      ),
    );
  }
}
