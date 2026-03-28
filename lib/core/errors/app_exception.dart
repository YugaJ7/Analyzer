import 'failures.dart';

class AppException implements Exception {
  final Failure failure;

  const AppException(this.failure);

  String get message => failure.message;

  @override
  String toString() =>
      'AppException(${failure.runtimeType}: ${failure.message})';
}
