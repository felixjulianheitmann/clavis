
import 'dart:io';

import 'package:clavis/l10n/app_localizations.dart';
import 'package:clavis/src/blocs/download_bloc.dart';
import 'package:clavis/src/blocs/page_bloc.dart';
import 'package:clavis/src/blocs/pref_bloc.dart';
import 'package:clavis/src/util/cache_image.dart';
import 'package:clavis/src/util/helpers.dart';
import 'package:clavis/src/util/hoverable.dart';
import 'package:clavis/src/util/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gamevault_client_sdk/api.dart';
import 'package:url_launcher/url_launcher.dart';

class GameBanner extends StatelessWidget {
  const GameBanner({
    super.key,
    required double bannerHeight,
    required double padding,
    required double titleOffset,
    required this.game,
  }) : _bannerHeight = bannerHeight, _padding = padding, _titleOffset = titleOffset;

  final double _bannerHeight;
  final double _padding;
  final double _titleOffset;
  final GamevaultGame game;

  @override
  Widget build(BuildContext context) {
    return 
    Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: _bannerHeight,
            child: _GameBanner(
              game.metadata?.background?.sourceUrl,
              _bannerHeight,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(_padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
      height:
          _bannerHeight +
          _GameTitle.fontSize +
          _padding +
          _titleOffset,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: [
          _GameCover(game),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _GameWebsites(game.metadata?.urlWebsites),
                    _GameTitle(title: game.title),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    )
              ],
            ),
          ),
        ],
      )
    ;
  }
}


class _GameWebsites extends StatelessWidget {
  const _GameWebsites(this.websites);
  final List<String>? websites;

  static const _iconLookup = <String, IconData>{
    "discorg.gg": Icons.discord,
    "steampowered.com": FontAwesomeIcons.steam,
    "youtube.com": FontAwesomeIcons.youtube,
    "facebook.com": FontAwesomeIcons.facebook,
    "twitter.com": FontAwesomeIcons.twitter,
    "x.com": FontAwesomeIcons.twitter,
    "en.wikipedia.org": FontAwesomeIcons.wikipediaW,
    "twitch.tv": FontAwesomeIcons.twitch,
    "reddit.com": FontAwesomeIcons.reddit,
    "instagram.com": FontAwesomeIcons.instagram,
  };

  IconButton? _toIconButton(String url) {
    IconData? iconData;
    for (var hostIcon in _iconLookup.entries) {
      if (url.contains(hostIcon.key)) {
        iconData = hostIcon.value;
      }
    }
    if (iconData != null) {
      return IconButton(
        icon: Icon(iconData),
        onPressed: () => launchUrl(Uri.parse(url)),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (websites == null) {
      return Container();
    }
    final elements = websites!.map((w) => _toIconButton(w)).nonNulls.toList();
    return Wrap(children: elements);
  }
}


class _GameBanner extends StatelessWidget {
  const _GameBanner(this.url, this.height);
  static const _defaultBannerImage = "assets/Key-Logo_Diagonal.png";
  final String? url;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return Image.asset(_defaultBannerImage, fit: BoxFit.cover);
    }
    return CacheImage(imageUrl: url!, fit: BoxFit.cover);
  }
}

class _GameCover extends StatefulWidget {
  const _GameCover(this.game);
  final GamevaultGame game;
  static const _coverWidth = 200.0;

  @override
  State<_GameCover> createState() => _GameCoverState();
}

class _GameCoverState extends State<_GameCover> {
  static const _downloadSize = 64.0;
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    final cover = Helpers.cover(widget.game, _GameCover._coverWidth);
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      return Card(clipBehavior: Clip.antiAlias, child: cover);
    }

    return Card(
      color: Colors.black,
      clipBehavior: Clip.antiAlias,
      child: Hoverable(
        alignment: AlignmentDirectional.center,
        background: cover,
        foreground: _GameDownloadButton(
          game: widget.game,
          downloadSize: _downloadSize,
          translate: translate,
        ),
      ),
    );
  }
}

class _GameDownloadButton extends StatelessWidget {
  const _GameDownloadButton({
    required this.game,
    required double downloadSize,
    required this.translate,
  }) : _downloadSize = downloadSize;

  final GamevaultGame game;
  final double _downloadSize;
  final AppLocalizations translate;

  void _triggerDownload(
    BuildContext context,
    ApiClient api,
    String downloadDir,
  ) {
    // try and trigger a direct browser download
    if (kIsWeb) {
      log.e("file download not yet supported on web");
      throw Error();
    } else {
      // use the download queuing mechanism
      context.read<DownloadBloc>().add(
        DlAdd(api: api, game: game, downloadDir: downloadDir),
      );
      context.read<PageBloc>().add(DlStarted(game.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final api = Helpers.getApi(context);
    final dlDir = context.select((PrefBloc p) => p.state.prefs.downloadDir);
    void Function()? cb;
    if (api != null && dlDir != null) {
      cb = () => _triggerDownload(context, api, dlDir);
    }
    
    final actionButton = IconButton(
      icon: Icon(Icons.download),
      onPressed: cb,
      iconSize: _downloadSize,
      color: Colors.white,
    );
    final label = _GameSizeText(game: game, translate: translate);

    return Card(
      color: Theme.of(context).canvasColor.withAlpha(127),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [actionButton, label],
        ),
      ),
    );
  }
}

class _GameSizeText extends StatelessWidget {
  const _GameSizeText({required this.game, required this.translate});

  final GamevaultGame game;
  final AppLocalizations translate;

  @override
  Widget build(BuildContext context) {
    return Text(
      Helpers.sizeStrInUnit(game.size!, translate),
      style: TextStyle(fontSize: 24, color: Colors.white),
    );
  }
}

class _GameTitle extends StatelessWidget {
  const _GameTitle({this.title});
  final String? title;

  static const fontSize = 48.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        final title = this.title ?? "missing title";
        final style = TextStyle(fontSize: fontSize);
        final textWidth =
            (TextPainter(
              text: TextSpan(text: title, style: style),
              textScaler: MediaQuery.of(context).textScaler,
              textDirection: TextDirection.ltr,
            )..layout()).size.width *
            1.05; // buffer because the measuring is slightly off

        var scale = 1.0;
        if (constraint.maxWidth < textWidth) {
          scale = constraint.maxWidth / textWidth;
        }
        return Text(title, style: style, textScaler: TextScaler.linear(scale));
      },
    );
  }
}
