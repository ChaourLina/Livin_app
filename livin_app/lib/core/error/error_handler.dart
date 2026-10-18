import 'package:firebase_auth/firebase_auth.dart';
import 'package:livin_app/core/error/either.dart';
import 'package:livin_app/core/error/exceptions.dart';
import 'package:livin_app/core/error/failure.dart';

AppException handleAuthError(FirebaseAuthException e) {
  switch (e.code) {
    case 'network-request-failed':
      return const NetworkException();
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return const UnauthorizedException();
    case 'invalid-email':
      return const ServerException('Adresse email invalide.');
    case 'email-already-in-use':
      return const ServerException('Cet email est déjà utilisé.');
    case 'weak-password':
      return const ServerException(
      'Mot de passe trop faible (6 caractères minimum).');
    case 'too-many-requests':
      return const ServerException('Trop de tentatives. Réessayez plus tard.');
    default:
      return const UnknownException();
  }
}

AppException handleFirestoreError(FirebaseException e) {
  switch (e.code) {
    case 'unavailable':
    case 'deadline-exceeded':
      return const NetworkException();
    case 'permission-denied':
    case 'unauthenticated':
      return const UnauthorizedException('Action non autorisée.');
    case 'not-found':
      return const NotFoundException();
    default:
      return const ServerException();
  }
}

Failure exceptionToFailure(AppException e) {
  if (e is EmailNotVerifiedException) return EmailNotVerifiedFailure(e.message);
  if (e is NetworkException) return NetworkFailure(e.message);
  if (e is UnauthorizedException) return UnauthorizedFailure(e.message);
  if (e is NotFoundException) return NotFoundFailure(e.message);
  if (e is ServerException) return ServerFailure(e.message);
  return UnknownFailure(e.message);
}

Future<Either<Failure, T>> guard<T>(Future<T> Function() action) async {
  try {
    return Either.right(await action());
  } on AppException catch (e) {
    return Either.left(exceptionToFailure(e));
  }
}