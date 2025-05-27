/// Exceptions personnalisées pour l'application
abstract class AppException implements Exception {
  final String message;
  final String? code;
  
  const AppException(this.message, [this.code]);
  
  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exception pour les erreurs de validation
class ValidationException extends AppException {
  const ValidationException(super.message, [super.code]);
}

/// Exception pour les erreurs de base de données
class DatabaseException extends AppException {
  const DatabaseException(super.message, [super.code]);
}

/// Exception pour les erreurs réseau
class NetworkException extends AppException {
  const NetworkException(super.message, [super.code]);
}

/// Exception pour les erreurs de fichier
class FileException extends AppException {
  const FileException(super.message, [super.code]);
}

/// Exception pour les erreurs de permission
class PermissionException extends AppException {
  const PermissionException(super.message, [super.code]);
}

/// Exception pour les erreurs de cache
class CacheException extends AppException {
  const CacheException(super.message, [super.code]);
}

/// Exception pour les erreurs d'authentification
class AuthException extends AppException {
  const AuthException(super.message, [super.code]);
}

/// Exception pour les erreurs de service
class ServiceException extends AppException {
  const ServiceException(super.message, [super.code]);
}
