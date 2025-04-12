import 'dart:io';

import 'package:clavis/src/util/logger.dart';
import 'package:clavis/src/repositories/pref_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';
import 'package:path/path.dart';

class DownloadProgress {
  const DownloadProgress({
    this.bytesRead = -1,
    this.bytesTotal = -1,
    this.hasError = false,
    this.isCancelled = false,
    this.isDone = false,
  });
  final int bytesRead;
  final int bytesTotal;
  final bool hasError;
  final bool isCancelled;
  final bool isDone;
}

class DownloadState {
  DownloadState({this.queue = const [], this.finished = const []});
  final List<int> queue;
  final List<int> finished;

  DownloadState copyWith({List<int>? queue}) {
    return DownloadState(queue: queue ?? this.queue);
  }
}

class DownloadAuthPendingState extends DownloadState {}

class DownloadReadyState extends DownloadState {
  DownloadReadyState({required this.api, super.queue, super.finished});
  final ApiClient api;

  static DownloadReadyState fromState(ApiClient api, DownloadState state) {
    return DownloadReadyState(
      api: api,
      finished: state.finished,
      queue: state.queue,
    );
  }
}

class DownloadActiveState extends DownloadReadyState {
  DownloadActiveState({
    required super.api,
    super.finished,
    super.queue,
    required this.progress,
  });
  final DownloadProgress progress;

  DownloadActiveState withProgress(DownloadProgress progress) {
    return DownloadActiveState(
      progress: progress,
      api: api,
      finished: finished,
      queue: queue,
    );
  }
}

class DownloadEvent {
  const DownloadEvent();
}

class DownloadAuthReceivedEvent extends DownloadEvent {
  const DownloadAuthReceivedEvent(this.api);
  final ApiClient api;
}

class DownloadsQueuedEvent extends DownloadEvent {
  const DownloadsQueuedEvent({required this.ids});
  final List<int> ids;
}

class DownloadCancelEvent extends DownloadEvent {
  const DownloadCancelEvent();
}

class DownloadRemovedEvent extends DownloadEvent {
  const DownloadRemovedEvent({required this.id});
  final int id;
}

class DownloadFinishedEvent extends DownloadEvent {
  const DownloadFinishedEvent({required this.id});
  final int id;
}

class DownloadFailedEvent extends DownloadEvent {
  const DownloadFailedEvent({required this.id});
  final int id;
}

class DownloadBloc extends Bloc<DownloadEvent, DownloadState> {
  DownloadBloc() : super(DownloadAuthPendingState()) {
    on<DownloadAuthReceivedEvent>((event, emit) {
      final newState = DownloadReadyState.fromState(event.api, state);
      emit(newState);
    });

    on<DownloadsQueuedEvent>((event, emit) async {
      if (state is DownloadReadyState) {
        final readyState = state as DownloadReadyState;
        // remove duplicates
        for (final id in event.ids) {
          if (readyState.queue.contains(id)) {
            event.ids.remove(id);
          }
        }

        final newQueue = readyState.queue + event.ids;

        if (newQueue.length == 1) {
          final uri =
              "${readyState.api.basePath}/api/games/${event.ids.first}/download";

          Map<String, String> headers = {};
          await readyState.api.authentication!.applyToParams([], headers);
          emit(
            DownloadActiveState(
              api: readyState.api,
              progress: DownloadProgress(),
              finished: readyState.finished,
              queue: readyState.queue,
            ),
          );

          final downloadDir = await Preferences.getDownloadDir();
          GamevaultGame? game;
          try {
            game = await GameApi(
              readyState.api,
            ).getGameByGameId(event.ids.first);
          } catch (e) {
            log.e("error querying game info", error: e);
          }

          if (game == null || downloadDir == null) {
            log.e("cannot download game - directory or game info missing");
            return;
          }

          final resp = await Dio().download(
            uri,
            join(downloadDir, basename(game.filePath)),
            onReceiveProgress: (count, total) {
              if (state is DownloadActiveState) {
                emit(
                  (state as DownloadActiveState).withProgress(
                    DownloadProgress(bytesRead: count, bytesTotal: total),
                  ),
                );
              }
            },
            options: Options(headers: headers),
          );

          if (resp.statusCode != HttpStatus.ok) {
            emit(
              (state as DownloadActiveState).withProgress(
                DownloadProgress(hasError: true),
              ),
            );
          }

          emit(
            (state as DownloadActiveState).withProgress(
              DownloadProgress(isDone: true),
            ),
          );
        }
      } else if (state.runtimeType is DownloadReadyState) {}
    });

    on<DownloadRemovedEvent>((event, emit) {
      if (!state.queue.contains(event.id)) {
        return;
      }
      state.queue.remove(event.id);
      emit(DownloadState(queue: state.queue));
    });

    on<DownloadFinishedEvent>((event, emit) {
      if (!state.queue.contains(event.id)) {
        return;
      }
      state.queue.remove(event.id);
      emit(DownloadState(queue: state.queue));
    });

    on<DownloadFailedEvent>((event, emit) {
      if (!state.queue.contains(event.id)) {
        return;
      }
      state.queue.remove(event.id);
      emit(DownloadState(queue: state.queue));
    });
  }
}
