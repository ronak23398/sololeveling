class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, [this.code]);

  @override
  String toString() => code != null ? '$code: $message' : message;
}

class AuthException extends AppException {
  AuthException(String message, [String? code]) : super(message, code);
}

class DatabaseException extends AppException {
  DatabaseException(String message, [String? code]) : super(message, code);
}

class NetworkException extends AppException {
  NetworkException(String message, [String? code]) : super(message, code);
}

class ValidationException extends AppException {
  ValidationException(String message, [String? code]) : super(message, code);
}

class LevelCalculationException extends AppException {
  LevelCalculationException(String message, [String? code])
      : super(message, code);
}
