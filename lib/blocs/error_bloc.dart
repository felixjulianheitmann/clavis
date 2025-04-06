import 'package:clavis/widgets/error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ErrorState {
  const ErrorState({this.error});
  final Object? error;
  bool get hasError => error != null;
}

class ErrorEvent {}

class ErrorNewEvent extends ErrorEvent {
  ErrorNewEvent({required this.error});
  final Object error;
}

class ErrorDismissEvent extends ErrorEvent {}

class ErrorBloc extends Bloc<ErrorEvent, ErrorState> {
  ErrorBloc() : super(ErrorState()) {
    on<ErrorNewEvent>((event, emit) => emit(ErrorState(error: event.error)));
    on<ErrorDismissEvent>((_, emit) => emit(ErrorState()));
  }

  static makeError(BuildContext ctx, Object error, bool dismissable) {
    if(dismissable) {
      showDialog(context: ctx, builder: (context) => ErrorDialog(error: error,));
      return;
    }
    ctx.read<ErrorBloc>().add(ErrorNewEvent(error: error));
  }
}