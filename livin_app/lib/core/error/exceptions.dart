class AppException implements Exception {
  final String message;
  const AppException(this.message);
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Pas de connexion internet.']);
}

class ServerException extends AppException {
  const ServerException([super.message = 'Erreur du serveur. Réessayez plus tard.']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Email ou mot de passe incorrect.']);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Ressource introuvable.']);
}

class UnknownException extends AppException {
  const UnknownException([super.message = 'Une erreur inconnue est survenue.']);
}