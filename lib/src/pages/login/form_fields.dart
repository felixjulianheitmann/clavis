import 'package:formz/formz.dart';

enum NonEmptyInputError { empty }
enum HostnameError { empty, invalidUri, notAvailable } // notAvailable not yet possible without async validation

class NonEmptyInput extends FormzInput<String, NonEmptyInputError> {
  const NonEmptyInput.pure({String init = ''}) : super.pure(init);
  const NonEmptyInput.dirty({String value = ''}) : super.dirty(value);

  @override
  NonEmptyInputError? validator(String value) {
    return value.isEmpty ? NonEmptyInputError.empty : null;
  }
}

typedef UsernameInput = NonEmptyInput;
typedef PasswordInput = NonEmptyInput;

class HostnameInput extends FormzInput<String, HostnameError> {
  const HostnameInput.pure({String init = ''}) : super.pure(init);
  const HostnameInput.dirty({String value = ''}) : super.dirty(value);

  @override
  HostnameError? validator(String hostname)  {
    if(hostname.isEmpty) return HostnameError.empty;

    try {
      Uri.parse('$hostname/api/health');
    } on FormatException {
      return HostnameError.invalidUri;
    }

    return null;
  }
}


class LoginFormz with FormzMixin {
  LoginFormz({
    this.host = const HostnameInput.pure(),
    this.user = const UsernameInput.pure(),
    this.pass = const PasswordInput.pure(),
    this.status = FormzSubmissionStatus.initial,
  });

  final HostnameInput host;
  final UsernameInput user;
  final PasswordInput pass;
  final FormzSubmissionStatus status;

  LoginFormz copyWith({
    HostnameInput? host,
    UsernameInput? user,
    PasswordInput? pass,
    FormzSubmissionStatus? status,
  }) {
    return LoginFormz(
    host: host?? this.host,
    user: user?? this.user,
    pass: pass?? this.pass,
    status: status?? this.status,
    );
  }

  @override
  List<FormzInput> get inputs => [host, user, pass];
}
