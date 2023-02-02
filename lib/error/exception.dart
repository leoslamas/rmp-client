import 'dart:io';

class RepositoryException extends IOException {
  final String message;

  RepositoryException(this.message);

  @override
  String toString() {
    return "RepositoryException: $message";
  }
}
