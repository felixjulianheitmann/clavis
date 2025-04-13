import 'dart:io';
import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:clavis/src/util/helpers.dart';
import 'package:clavis/src/util/hoverable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gamevault_client_sdk/api.dart';
import 'package:clavis/src/clavis_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:clavis/l10n/app_localizations.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key, required this.game});

  final GamevaultGame game;

  @override
  Widget build(BuildContext context) {
    var actions = <Widget>[];
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      actions += [
        // BlocBuilder<DownloadBloc, DownloadState>(
        //   builder: (context, state) {
        //     return IconButton(
        //       icon: Icon(Icons.download),
        //       onPressed: () {
        //         if (state is DownloadReadyState) {
        //           context.read<DownloadBloc>().add(
        //             DownloadsQueuedEvent(ids: [game.id as int]),
        //           );
        //         }
        //       },
        //     );
        //   },
        // ),
      ];
    }
    return ClavisScaffold(
      title: game.title,
      body: _GameTitleBoard(game),
      showDrawer: false,
      actions: actions,
    );
  }
}

class _GameTitleBoard extends StatelessWidget {
  const _GameTitleBoard(this.game);
  final GamevaultGame game;

  static const _padding = 16.0;
  static const _bannerHeight = 250.0;
  static const _titleOffset = 40.0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
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
                ),
                _GameDescription(game.metadata?.description),
                _GameScreenshots(game.metadata?.urlScreenshots),
              ],
            ),
          ),
        ],
      ),
    );
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

class _GameTrailer extends StatefulWidget {
  const _GameTrailer(this.trailerUrls);
  final List<String>? trailerUrls;

  @override
  State<_GameTrailer> createState() => _GameTrailerState();
}

class _GameTrailerState extends State<_GameTrailer> {
  _GameTrailerState() {
    if (widget.trailerUrls != null && widget.trailerUrls!.isNotEmpty) {
      controller.cuePlaylist(list: widget.trailerUrls!);
    }
  }
  final controller = YoutubePlayerController();

  @override
  Widget build(BuildContext context) {
    if (widget.trailerUrls!.isEmpty) {
      return Container();
    }
    return YoutubePlayer(controller: controller);
  }
}

class _GameScreenshots extends StatefulWidget {
  const _GameScreenshots(this.screenShotUrls);
  final List<String>? screenShotUrls;

  @override
  State<StatefulWidget> createState() => _GameScreenshotsState();
}

class _GameScreenshotsState extends State<_GameScreenshots> {
  final controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    if (widget.screenShotUrls == null) {
      return Container();
    }

    final screenW = MediaQuery.of(context).size.width;

    final opts = ExpandableCarouselOptions(
      autoPlay: true,
      viewportFraction: min(0.8, 500 / screenW),
      enableInfiniteScroll: true,
      enlargeCenterPage: true,
    );

    return ExpandableCarousel.builder(
      options: opts,
      itemCount: widget.screenShotUrls!.length,
      itemBuilder: (context, index, realIndex) {
        final img = Image.network(widget.screenShotUrls![index]);
        final fullScreenDialog = Dialog.fullscreen(
          child: FullScreenImg(widget.screenShotUrls!, index),
        );

        return GestureDetector(
          onTap: () {
            showDialog(context: context, builder: (_) => fullScreenDialog);
          },
          child: Card(clipBehavior: Clip.antiAlias, child: img),
        );
      },
    );
  }
}

class FullScreenImg extends StatelessWidget {
  const FullScreenImg(this.urls, this.initialIdx, {super.key});

  final List<String> urls;
  final int initialIdx;

  @override
  Widget build(BuildContext context) {
    final imgs = urls.map((url) => Image.network(url)).toList();
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 32),
          child: Align(
            alignment: Alignment.topCenter,
            child: FloatingActionButton(
              backgroundColor: Theme.of(context).splashColor,
              onPressed: () => Navigator.pop(context),
              child: Icon(Icons.close),
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ExpandableCarousel(
              items: imgs,
              options: ExpandableCarouselOptions(
                viewportFraction: 1.0,
                initialPage: initialIdx,
                enableInfiniteScroll: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GameDescription extends StatelessWidget {
  const _GameDescription(this.description);
  final String? description;

  static const _elevation = 2.0;
  static const _padding = EdgeInsets.all(8);

  @override
  Widget build(BuildContext context) {
    var desc = Text("no description available");
    if (description != null) {
      desc = Text(description!);
    }
    return Card(
      elevation: _elevation,
      child: Padding(padding: _padding, child: desc),
    );
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
    return Image.network(url!, fit: BoxFit.cover);
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

  // void _triggerDownload(BuildContext context) {
  //   // try and trigger a direct browser download
  //   if (kIsWeb) {
  //     log.e("file download not yet supported on web");
  //     throw Error();
  //   } else {
  //     // use the download queuing mechanism
  //     context.read<DownloadBloc>().add(
  //       DownloadsQueuedEvent(ids: [game.id as int]),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final actionButton = IconButton(
      icon: Icon(Icons.download),
      onPressed: null,
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
      Helpers.sizeInUnit(game.size, translate),
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
