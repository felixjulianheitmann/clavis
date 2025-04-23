import 'package:clavis/src/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum PageId { games, users, userMe, settings, downloads }

enum DlSnackVisibility { visible, dismissed, hiddenOnDlPage }

class DlSnackBarState {
  num? activeDl;
  DlSnackVisibility visibility = DlSnackVisibility.visible;
}

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
  PageState({required this.activePage, required this.dlSnack});
  final PageInfo activePage;
  final DlSnackBarState dlSnack;

  PageState copyWith({PageInfo? activePage, DlSnackBarState? dlSnack}) {
    return PageState(
      activePage: activePage ?? this.activePage,
      dlSnack: dlSnack ?? this.dlSnack,
    );
  }
}

class PageEvent {}
class PageChanged extends PageEvent {
  PageChanged(this.newPage);
  final PageInfo newPage;
}
class DlStarted extends PageEvent {
  DlStarted(this.gameId);
  final num gameId;
}

class PageBloc extends Bloc<PageEvent, PageState>{
  PageBloc()
    : super(
        PageState(
          activePage: Constants.gamesPageInfo(),
          dlSnack: DlSnackBarState(),
        ),
      ) {
    on<PageChanged>((event, emit) {
      var dlSnack = state.dlSnack;
      if (dlSnack.visibility != DlSnackVisibility.dismissed &&
          event.newPage.id == Constants.downloadsPageInfo().id) {
        // hide visibilty temporarily
        dlSnack.visibility = DlSnackVisibility.hiddenOnDlPage;
      } else if (dlSnack.visibility == DlSnackVisibility.hiddenOnDlPage &&
          event.newPage.id != Constants.downloadsPageInfo().id) {
        dlSnack.visibility = DlSnackVisibility.visible;
      }

      emit(PageState(activePage: event.newPage, dlSnack: dlSnack));
    });
    on<DlStarted>((event, emit) {
      var dlSnack = DlSnackBarState();
      dlSnack.activeDl = event.gameId;
      emit(state.copyWith(dlSnack: dlSnack));
    });
  }
}