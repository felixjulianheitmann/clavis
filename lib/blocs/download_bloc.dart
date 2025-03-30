import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamevault_client_sdk/api.dart';
import 'package:http/http.dart';
import 'package:worker_manager/worker_manager.dart';


class DownloadProgress {
  const DownloadProgress({
    required this.resp,
    this.chunk,
    this.hasError = false,
    this.isCancelled = false,
    this.isDone = false,
  });
  final List<int>? chunk;
  final bool hasError;
  final bool isCancelled;
  final bool isDone;
  final StreamedResponse resp;
}
class DownloadState {
  DownloadState({this.queue = const [], this.finished = const []});
  final List<int> queue;
  final List<int> finished;

  DownloadState copyWith({List<int>? queue}) {
    return DownloadState(
      queue: queue ?? this.queue,
    );
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
    required this.progress,
    required super.api,
    super.finished,
    super.queue,
  });
  final DownloadProgress progress;
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

    on<DownloadsQueuedEvent>((event, emit) {
      switch (state.runtimeType) {
        case const (DownloadReadyState):
          final availableState = state as DownloadReadyState;
          // remove duplicates
          for (final id in event.ids) {
            if (availableState.queue.contains(id)) {
              event.ids.remove(id);
            }
          }

          final newState = availableState.copyWith(
            queue: availableState.queue + event.ids,
          );
          if (availableState.queue.length == 1) {
            final activeDownloadTask = workerManager.executeGentleWithPort(
              _startGameDownload(availableState.api, event.ids[0]),
              onMessage:
                  (DownloadProgress progress) => emit(
                    DownloadActiveState(
                      progress: progress,
                      api: availableState.api,
                    ),
                  ),
            );
          }
          emit(newState);
          break;
        case const (DownloadAuthPendingState):
      }
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

Future<Null> Function(dynamic, dynamic) _startGameDownload(
  ApiClient api,
  int gameId,
) {
  return (sendPort, isCancelled) async {
    final uri = Uri.parse("${api.basePath}/api/games/$gameId/download");
    final client = StreamedRequest('GET', uri);
    final resp = await api.client.send(client);
    try {
      await for (final chunk in resp.stream) {
        if (isCancelled()) {
          sendPort.send(DownloadProgress(resp: resp, isCancelled: true));
        }
        sendPort.send(DownloadProgress(resp: resp, chunk: chunk));
      }
    } catch (e) {
      sendPort.send(DownloadProgress(resp: resp, hasError: true));
    }
    sendPort.send(DownloadProgress(resp: resp, isDone: true));
  };
}
