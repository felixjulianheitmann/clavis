import 'package:clavis/src/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum PageId { games, users, userMe, settings, downloads }

class PageInfo {
  const PageInfo({
    required this.id,
    this.appbarActions = const [],
    this.blocs = const [],
  });
  final PageId id;
  final List<Widget> appbarActions;
  final List<Bloc Function(BuildContext ctx)> blocs;
}

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