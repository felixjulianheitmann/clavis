import 'package:clavis/blocs/error_bloc.dart';
import 'package:clavis/util/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gamevault_client_sdk/api.dart';
import 'package:clavis/blocs/auth_bloc.dart';

typedef QueryBuildFunction<T> =
    Widget Function(BuildContext context, T?, Object? error);
typedef QueryFunction<T> = Future<T>? Function(ApiClient api);

/// tries to wrap the async query + waiting code into a widget
/// gets passed a query function which is executed to perform the query and
/// a builder function which is passed the result of the query when available
class Querybuilder<T> extends StatefulWidget {
  const Querybuilder({super.key, required this.query, required this.builder});

  final QueryFunction<T> query;
  final QueryBuildFunction<T> builder;

  @override
  State<StatefulWidget> createState() => QuerybuilderState<T>();
}

class QuerybuilderState<T> extends State<Querybuilder<T>> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final spinner = Center(child: SpinKitCircle(color: Colors.blue));
        if (state is! AuthSuccessState) {
          return spinner;
        }

        return FutureBuilder<T>(
          future: widget.query(state.api),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return widget.builder(context, snapshot.data, null);
            } else if (snapshot.hasError) {
              log.e('error finishing query', error: snapshot.error);
              context.read<ErrorBloc>().add(
                ErrorNewEvent(error: snapshot.error!),
              );
              return widget.builder(context, null, snapshot.error as Object);
            }
            return spinner;
          },
        );
      },
    );
  }
}
