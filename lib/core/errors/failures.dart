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

// Hive / local cache read-write errors.
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

//Firebase Auth errors with human-readable messages.
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

// User dismissed the sign-in flow; not an error to report.
class AuthCancelledFailure extends AuthFailure {
  const AuthCancelledFailure() : super('Sign-in was cancelled.');
}

// Device has no internet connection.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

// Client-side input validation failed before any network call.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
