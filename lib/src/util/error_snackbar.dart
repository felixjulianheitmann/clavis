import 'package:clavis/src/repositories/error_repository.dart';
import 'package:flutter/material.dart';

SnackBar errorSnack(BuildContext context, ClavisError err) {
  return SnackBar(
    backgroundColor: Theme.of(context).colorScheme.error,
    duration: Duration(seconds: 15),
    showCloseIcon: true,
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.all(16),
    content: Builder(
      builder: (context) {

    return Text(err.err.toString());
  },));
}