class Failure implements Exception {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Pas de connexion internet.']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Erreur du serveur. Réessayez plus tard.']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Email ou mot de passe incorrect.']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Ressource introuvable.']);
}

class EmailNotVerifiedFailure extends Failure {
  const EmailNotVerifiedFailure(
  [super.message = 'Email non vérifié. Vérifiez votre boîte mail.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Une erreur inconnue est survenue.']);
}