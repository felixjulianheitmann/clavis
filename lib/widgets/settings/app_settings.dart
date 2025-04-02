import 'package:flutter/material.dart';

class AppSettings extends StatelessWidget {
  const AppSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Launch on boot"),
        Text("Minimize ?"),
        Text("Theme - light, dark, oled"),
        Text("DownloadDir"),
        //
        // Server
        Text("clear Cache images"),
        Text("clear cache offline"),
        // download and install
        Text("Download bandwidth"),
        Text("Extraction auto extract"),
        Text("Extraction auto password"),
        Text("Mount ISO instead of extraction"),
        Text("Auto install portables"),
        Text("Auto delete portable games install files"),
      ],
    );
  }
}

