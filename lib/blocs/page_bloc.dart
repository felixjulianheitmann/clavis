import 'package:clavis/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PageState{
  PageState(this.activePage);
  final PageInfo activePage; 
}

class PageEvent {}
class PageChangedEvent extends PageEvent {
  PageChangedEvent(this.newPage);
  final PageInfo newPage;
}

class PageBloc extends Bloc<PageEvent, PageState>{
  PageBloc() : super(PageState(Constants.gamesPageInfo())) {
    on<PageChangedEvent>((event, emit) => emit(PageState(event.newPage)));
  }
}