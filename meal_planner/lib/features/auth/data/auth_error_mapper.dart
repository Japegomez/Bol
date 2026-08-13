import 'package:flutter/services.dart';
import 'package:meal_planner/features/auth/domain/auth_exception.dart'
    as app_auth;
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

app_auth.AuthException mapAuthError(Object error) {
  if (error is app_auth.AuthException) {
    return error;
  }

  final googleSignInError = mapGoogleSignInError(error);
  if (googleSignInError != null) {
    return googleSignInError;
  }

  if (error is AuthApiException) {
    final code = error.code?.toLowerCase() ?? '';
    final message = error.message.toLowerCase();

    if (code == 'invalid_credentials' ||
        message.contains('invalid login credentials') ||
        message.contains('invalid credentials')) {
      return const app_auth.AuthInvalidCredentialsException();
    }

    if (code == 'email_not_confirmed' ||
        message.contains('email not confirmed')) {
      return const app_auth.AuthEmailNotConfirmedException();
    }

    if (code == 'user_already_exists' ||
        code == 'email_exists' ||
        message.contains('user already registered') ||
        message.contains('already been registered')) {
      return const app_auth.AuthUserAlreadyExistsException();
    }

    if (code == 'captcha_failed' ||
        code.contains('captcha') ||
        message.contains('captcha')) {
      return const app_auth.AuthCaptchaException();
    }

    return app_auth.AuthProviderException(error.message);
  }

  return app_auth.AuthProviderException(error.toString());
}

/// Maps [PlatformException] from `google_sign_in` (e.g. ApiException: 10).
app_auth.AuthException? mapGoogleSignInError(Object error) {
  if (error is! PlatformException) return null;

  if (error.code != 'sign_in_failed') {
    return app_auth.AuthProviderException(
      'No se pudo iniciar sesión con Google (${error.code}).',
    );
  }

  final message = error.message ?? '';
  // ApiException 10 / DEVELOPER_ERROR — SHA-1 or OAuth client mismatch on Android.
  if (message.contains(': 10') ||
      message.contains('10:') ||
      message.contains('ApiException: 10') ||
      message.contains('DEVELOPER_ERROR')) {
    return const app_auth.AuthGoogleSignInConfigurationException();
  }

  return const app_auth.AuthProviderException(
    'No se pudo iniciar sesión con Google. Inténtalo de nuevo.',
  );
}
