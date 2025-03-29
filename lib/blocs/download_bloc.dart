import 'package:flutter_bloc/flutter_bloc.dart';

class DownloadState {
  const DownloadState({required this.downloadProgress, required this.queue});
  final Map<int, double> downloadProgress;
  final List<int> queue;

  DownloadState copyWith({Map<int, double>? progresses, List<int>? queue}) {
    return DownloadState(
      downloadProgress: progresses ?? downloadProgress,
      queue: queue ?? this.queue,
    );
  }
}

class DownloadEvent {}

class DownloadQueuedEvent extends DownloadEvent {
  DownloadQueuedEvent({required this.id});
  final int id;
}

class DownloadRemovedEvent extends DownloadEvent {
  DownloadRemovedEvent({required this.id});
  final int id;
}

class DownloadFinishedEvent extends DownloadEvent {
  DownloadFinishedEvent({required this.id});
  final int id;
}

class DownloadFailedEvent extends DownloadEvent {
  DownloadFailedEvent({required this.id});
  final int id;
}

class DownloadBloc extends Bloc<DownloadEvent, DownloadState> {
  DownloadBloc() : super(DownloadState(downloadProgress: {}, queue: [])) {
    on<DownloadQueuedEvent>((event, emit) {
      if(state.queue.contains(event.id)) {
        return;
      }
      emit(state.copyWith(queue: state.queue + [event.id]));
    });

    on<DownloadRemovedEvent>((event, emit) {
      if(!state.queue.contains(event.id)) {
        return;
      }
      state.queue.remove(event.id);
      emit(DownloadState(downloadProgress: state.downloadProgress, queue: state.queue));
    });

    on<DownloadFinishedEvent>((event, emit) {
      if(!state.queue.contains(event.id)) {
        return;
      }
      state.queue.remove(event.id);
      emit(DownloadState(downloadProgress: state.downloadProgress, queue: state.queue));  
    },);

    on<DownloadFailedEvent>((event, emit) {
      if(!state.queue.contains(event.id)) {
        return;
      }
      state.queue.remove(event.id);
      emit(DownloadState(downloadProgress: state.downloadProgress, queue: state.queue));  
    },);

  }
}
