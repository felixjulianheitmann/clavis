import 'package:carousel_slider/carousel_slider.dart';
import 'package:clavis/helpers.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gamevault_client_sdk/api.dart';
import 'package:clavis/widgets/clavis_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

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
                      _padding,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [_GameCover(game), _GameTitle(title: game.title)],
                  ),
                ),
                _GameDescription(game.metadata?.description),
                _GameScreenshots(game.metadata?.urlScreenshots),
                // _GameTrailer(game.metadata?.urlTrailers),
                _GameWebsites(game.metadata?.urlWebsites),
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
    "www.discorg.gg": Icons.discord,
    "store.steampowered.com": FontAwesomeIcons.steam,
    "www.youtube.com": FontAwesomeIcons.youtube,
    "www.epicgames.com": FontAwesomeIcons.store,
    "www.facebook.com": FontAwesomeIcons.facebook,
    "www.twitter.com": FontAwesomeIcons.twitter,
    "www.x.com": FontAwesomeIcons.twitter,
    "en.wikipedia.org": FontAwesomeIcons.wikipediaW,
    "www.twitch.tv": FontAwesomeIcons.twitch,
    "www.reddit.com": FontAwesomeIcons.reddit,
  };

  Icon _toIcon(String url) {
    final iconData = _iconLookup[Uri.parse(url).host];
    if (iconData == null) {
      return Icon(Icons.language);
    }
    return Icon(iconData);
  }

  @override
  Widget build(BuildContext context) {
    if (websites == null) {
      return Container();
    }
    final elements =
        websites!
            .map(
              (w) => IconButton(
                icon: _toIcon(w),
                onPressed: () => launchUrl(Uri.parse(w)),
              ),
            )
            .toList();
    return Row(children: elements);
  }
}

class _GameTrailer extends StatefulWidget {
  const _GameTrailer(this.trailerUrls);
  final List<String>? trailerUrls;

  static const _height = 200;

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

class _GameCover extends StatelessWidget {
  const _GameCover(this.game);
  final GamevaultGame game;
  static const _coverWidth = 250.0;
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Helpers.cover(game, _coverWidth),
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
      padding: EdgeInsets.all(_titlePadding),
      child: Text(title, style: TextStyle(fontSize: fontSize)),
    );
  }
}
