abstract class Failure {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.statusCode});
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.statusCode});
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException(this.message, {this.statusCode});
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);
}

class AuthException implements Exception {
  final String message;
  final int? statusCode;

  const AuthException(this.message, {this.statusCode});
}
