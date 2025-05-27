import 'package:equatable/equatable.dart';

/// Classe de base pour tous les échecs (failures) dans l'application
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  
  const Failure(this.message, [this.code]);
  
  @override
  List<Object?> get props => [message, code];
  
  @override
  String toString() => 'Failure: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Échec de validation
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, [super.code]);
}

/// Échec de base de données
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, [super.code]);
}

/// Échec réseau
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, [super.code]);
}

/// Échec de fichier
class FileFailure extends Failure {
  const FileFailure(super.message, [super.code]);
}

/// Échec de permission
class PermissionFailure extends Failure {
  const PermissionFailure(super.message, [super.code]);
}

/// Échec de cache
class CacheFailure extends Failure {
  const CacheFailure(super.message, [super.code]);
}

/// Échec inattendu
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message, [super.code]);
}
