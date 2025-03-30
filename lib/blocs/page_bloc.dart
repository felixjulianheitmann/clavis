import 'package:clavis/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PageState{
  PageState(this.activePage);
  final String activePage; 
}

class PageEvent {}
class PageChangedEvent extends PageEvent {
  PageChangedEvent(this.newPage);
  final String newPage;
}

class PageBloc extends Bloc<PageEvent, PageState>{
  PageBloc() : super(PageState(Constants.gamesPageKey)) {
    on<PageChangedEvent>((event, emit) => emit(PageState(event.newPage)));
  }
}