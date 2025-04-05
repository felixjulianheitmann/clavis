import 'package:clavis/widgets/games/page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GamesSearch extends StatefulWidget {
  const GamesSearch({super.key});

  @override
  State<GamesSearch> createState() => _GamesSearchState();
}

class _GamesSearchState extends State<GamesSearch> {
  TextEditingController textCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        Widget search = IconButton(
          onPressed: () => context.read<SearchBloc>().add(SearchOpenedEvent()),
          icon: Icon(Icons.search),
        );
        if (state.open) {
          search = ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width,
            ),
            child: SearchAnchor(
              builder: (context, controller) {
                return SearchBar(
                  controller: textCtrl,
                  leading: Icon(Icons.search),
                  onChanged:
                      (value) => context.read<SearchBloc>().add(
                        SearchChangedEvent(text: textCtrl.text),
                      ),
                  trailing: [
                    IconButton(
                      onPressed: () {
                        setState(() => textCtrl.value = TextEditingValue.empty);
                        context.read<SearchBloc>().add(SearchClosedEvent());
                      },
                      icon: Icon(Icons.clear),
                    ),
                  ],
                );
              },
              suggestionsBuilder: (context, controller) {
                return [];
              },
            ),
          );
        }

        return AnimatedSwitcher(
          duration: Duration(milliseconds: 100),
          transitionBuilder:
              (child, animation) => ScaleTransition(
                scale: animation,
                alignment: Alignment.centerRight,
                child: child,
              ),
          child: search,
        );
        
      },
    );
  }
}
