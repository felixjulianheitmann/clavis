import 'dart:io';
import 'dart:math';

import 'package:clavis/src/pages/games/game_banner.dart';
import 'package:clavis/src/pages/games/game_progress_card.dart';
import 'package:clavis/src/util/cache_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:gamevault_client_sdk/api.dart';
import 'package:clavis/src/clavis_scaffold.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

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
      body: _PageBody(game),
      showDrawer: false,
      actions: actions,
    );
  }
}

class _PageBody extends StatelessWidget {
  const _PageBody(this.game);
  final GamevaultGame game;

  static const _padding = 16.0;
  static const _bannerHeight = 250.0;
  static const _titleOffset = 40.0;

  @override
  Widget build(BuildContext context) {
    
    return SingleChildScrollView(
      child: Column(
        children: [
          GameBanner(
            bannerHeight: _bannerHeight,
            titleOffset: _titleOffset,
            padding: _padding,
            game: game,
          ),
          GameProgressCard(gameId: game.id),
          _GameDescription(game.metadata?.description),
          _GameScreenshots(game.metadata?.urlScreenshots),

        ],
      ),
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
  @override
  Widget build(BuildContext context) {
    if (widget.screenShotUrls == null || widget.screenShotUrls!.isEmpty) {
      return SizedBox.shrink();
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
        final img = CacheImage(imageUrl: widget.screenShotUrls![index]);
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
    final imgs = urls.map((url) => CacheImage(imageUrl: url)).toList();
    return Stack(
      children: [
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
      ],
    );
  }
}
