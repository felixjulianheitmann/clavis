import 'package:clavis/src/repositories/error_repository.dart';
import 'package:flutter/material.dart';

SnackBar errorSnack(ClavisError err) {
  return SnackBar(content: Builder(builder: (context) {
    return Text(err.err.toString());
  },));
}