abstract class Failure {
  final String message;
  const Failure(this.message);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Failure && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'Failure(message: $message)';
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}

class ImportExportFailure extends Failure {
  const ImportExportFailure(super.message);
}

class MediaFailure extends Failure {
  const MediaFailure(super.message);
}
