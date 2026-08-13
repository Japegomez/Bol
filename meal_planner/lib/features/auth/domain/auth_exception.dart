sealed class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class AuthCancelledException extends AuthException {
  const AuthCancelledException() : super('Sign-in cancelled');
}

final class AuthConfigurationException extends AuthException {
  const AuthConfigurationException(super.message);
}

final class AuthGoogleSignInConfigurationException extends AuthException {
  const AuthGoogleSignInConfigurationException()
    : super(
        'Google Sign-In no está configurado para esta build de Android. '
        'Registra el SHA-1 (debug o release/Play App Signing) en Google Cloud '
        'y Firebase, vuelve a descargar google-services.json y reinstala la app.',
      );
}

final class AuthProviderException extends AuthException {
  const AuthProviderException(super.message, {this.code, this.description});

  static const googleSignInFailedCode = 'google_sign_in_failed';

  final String? code;
  final String? description;
}

final class AuthInvalidCredentialsException extends AuthException {
  const AuthInvalidCredentialsException()
    : super(
        'Email o contraseña incorrectos. Comprueba los datos e inténtalo de nuevo.',
      );
}

final class AuthEmailNotConfirmedException extends AuthException {
  const AuthEmailNotConfirmedException()
    : super(
        'Confirma tu email antes de iniciar sesión. Revisa tu bandeja de entrada.',
      );
}

final class AuthUserAlreadyExistsException extends AuthException {
  const AuthUserAlreadyExistsException()
    : super(
        'Ya existe una cuenta con este email. Inicia sesión o usa otra dirección.',
      );
}

final class AuthPasswordTooWeakException extends AuthException {
  const AuthPasswordTooWeakException()
    : super(
        'La contraseña debe incluir una minúscula, una mayúscula, un número y un símbolo.',
      );
}

final class AuthInvalidCurrentPasswordException extends AuthException {
  const AuthInvalidCurrentPasswordException()
    : super('La contraseña actual no es correcta.');
}

final class AuthReauthenticationException extends AuthException {
  const AuthReauthenticationException()
    : super('Debes volver a autenticarte para continuar.');
}

final class AuthSamePasswordException extends AuthException {
  const AuthSamePasswordException()
    : super('La nueva contraseña debe ser distinta de la actual.');
}

final class AuthCaptchaException extends AuthException {
  const AuthCaptchaException() : super('captcha_failed');
}
