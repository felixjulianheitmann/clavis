import 'package:carousel_slider/carousel_slider.dart';
import 'package:clavis/blocs/download_bloc.dart';
import 'package:clavis/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gamevault_client_sdk/api.dart';
import 'package:clavis/widgets/clavis_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key, required this.game});

  final GamevaultGame game;

  @override
  Widget build(BuildContext context) =>
      ClavisScaffold(body: _GameTitleBoard(game));
}

class _GameTitleBoard extends StatelessWidget {
  const _GameTitleBoard(this.game);
  final GamevaultGame game;

  static const _padding = 16.0;
  static const _bannerHeight = 400.0;
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
              children: [
                SizedBox(
                  height:
                      _bannerHeight +
                      _GameTitle.fontSize +
                      _GameTitle._titlePadding +
                      _padding +
                      _titleOffset,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _GameCover(game),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _GameWebsites(game.metadata?.urlWebsites),
                          _GameTitle(title: game.title),
                        ],
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
    return Padding(
      padding: EdgeInsets.only(left: 24),
      child: Row(children: elements),
    );
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

  static const _imageHeight = 600.0;

  @override
  Widget build(BuildContext context) {
    if (widget.screenShotUrls == null) {
      return Container();
    }

    final images =
        widget.screenShotUrls!
            .map(
              (url) =>
                  Card(clipBehavior: Clip.antiAlias, child: Image.network(url)),
            )
            .toList();

    return CarouselSlider(
      items: images,
      options: CarouselOptions(
        enlargeCenterPage: true,
        enlargeStrategy: CenterPageEnlargeStrategy.height,
        height: _imageHeight,
      ),
      carouselController: controller,
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
  static const _coverWidth = 250.0;

  @override
  State<_GameCover> createState() => _GameCoverState();
}

class _GameCoverState extends State<_GameCover> {
  static const _hoverOpacity = 0.5;
  static const _animationDur = Duration(milliseconds: 150);
  static const _downloadSize = 64.0;
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    return Card(
      color: Colors.black,
      clipBehavior: Clip.antiAlias,
      child: MouseRegion(
        onEnter: (_) => setState(() => isHovering = true),
        onExit: (_) => setState(() => isHovering = false),
        child: AnimatedOpacity(
          duration: _animationDur,
          opacity: isHovering ? _hoverOpacity : 1.0,
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Helpers.cover(widget.game, _GameCover._coverWidth),
              AnimatedOpacity(
                opacity: isHovering ? 1.0 : 0.0,
                duration: _animationDur,
                child: _GameDownloadButton(
                  widget: widget,
                  downloadSize: _downloadSize,
                  translate: translate,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameDownloadButton extends StatelessWidget {
  const _GameDownloadButton({
    required this.widget,
    required double downloadSize,
    required this.translate,
  }) : _downloadSize = downloadSize;

  final _GameCover widget;
  final double _downloadSize;
  final AppLocalizations translate;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloadBloc, DownloadState>(
      builder: (context, state) {
        IconButton actionButton;
        Widget label;
        if (state is DownloadActiveState) {
          actionButton = IconButton(
            icon: Icon(Icons.cancel),
            onPressed: () {
              context.read<DownloadBloc>().add(DownloadCancelEvent());
            },
            iconSize: _downloadSize,
            color: Colors.white,
          );
          label = CircularProgressIndicator(
            color: Colors.white,
            value: state.progress.bytesRead / state.progress.bytesTotal,
          );
        } else {
          actionButton = IconButton(
            icon: Icon(Icons.download),
            onPressed:
                () => context.read<DownloadBloc>().add(
                  DownloadsQueuedEvent(ids: [widget.game.id as int]),
                ),
            iconSize: _downloadSize,
            color: Colors.white,

          );
          label = _GameSizeText(widget: widget, translate: translate);
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [actionButton, label],
        );
      },
    );
  }
}

class _GameSizeText extends StatelessWidget {
  const _GameSizeText({required this.widget, required this.translate});

  final _GameCover widget;
  final AppLocalizations translate;

  @override
  Widget build(BuildContext context) {
    return Text(
      Helpers.sizeInUnit(widget.game.size, translate),
      style: TextStyle(fontSize: 24, color: Colors.white),
    );
  }
}

class _GameTitle extends StatelessWidget {
  const _GameTitle({this.title});
  final String? title;

  static const _titlePadding = 24.0;
  static const fontSize = 48.0;

  @override
  Widget build(BuildContext context) {
    final title = this.title ?? "missing title";
    return Padding(
      padding: EdgeInsets.only(left: _titlePadding, bottom: _titlePadding),
      child: Text(title, style: TextStyle(fontSize: fontSize)),
    );
  }
}
