import 'package:flutter/material.dart';

class TextInput extends StatefulWidget {
  const TextInput({super.key, required this.label, this.validator, this.onSubmit });

  final String label;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmit;

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  final _formFieldCtrl = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(labelText: widget.label),
      controller: _formFieldCtrl,
      validator: widget.validator ?? (_) => null,
      onFieldSubmitted: widget.onSubmit ?? (_) {},
    );
  }
}