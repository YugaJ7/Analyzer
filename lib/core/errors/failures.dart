abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

// Firestore / network server-side errors.
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

//Firebase Auth errors with human-readable messages.
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

// User dismissed the sign-in flow; not an error to report.
class AuthCancelledFailure extends AuthFailure {
  const AuthCancelledFailure() : super('Sign-in was cancelled.');
}
