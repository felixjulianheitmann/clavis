import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gamevault_client_sdk/api.dart';
import 'package:gamevault_web/blocs/credential_bloc.dart';

typedef QueryBuildFunction<T> = Widget Function(BuildContext, T);
typedef QueryFunction<T> = Future<T?> Function(ApiClient);

/// tries to wrap the async query + waiting code into a widget
/// gets passed a query function which is executed to perform the query and
/// a builder function which is passed the result of the query when available
class Querybuilder extends StatefulWidget{
  const Querybuilder({super.key, required this.query, required this.builder, this.onError});

  final QueryFunction query;
  final QueryBuildFunction builder;
  final Function(Object)? onError;

  @override
  State<StatefulWidget> createState() => QuerybuilderState();
}

class QuerybuilderState extends State<Querybuilder> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final spinner = Center(child: SpinKitCircle(color: Colors.blue));
        if (state is! AuthSuccessfulState) {
          return spinner;
        }

        return FutureBuilder(
          future: widget.query(state.api),
          builder: (context, snapshot) {
          if(snapshot.hasData) {
              return widget.builder(context, snapshot.data);
          } else if (snapshot.hasError && widget.onError != null) {
            widget.onError!(snapshot.error!);
          }
          return spinner;
        });
      },
    );
  }
}