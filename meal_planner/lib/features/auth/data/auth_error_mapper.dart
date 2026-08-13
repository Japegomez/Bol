import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  if (error is AuthException) {
    final code = error.code?.toLowerCase() ?? '';
    final message = error.message.toLowerCase();

    if (error is AuthWeakPasswordException ||
        code == 'weak_password' ||
        message.contains('weak password')) {
      return const app_auth.AuthPasswordTooWeakException();
    }

    if (code == 'same_password' ||
        message.contains('should be different from the old password')) {
      return const app_auth.AuthSamePasswordException();
    }

    if (code == 'current_password_invalid' ||
        code == 'current_password_required' ||
        message.contains('current password required')) {
      return const app_auth.AuthInvalidCurrentPasswordException();
    }

    if (code == 'reauthentication_needed' ||
        code == 'reauthentication_not_valid') {
      return const app_auth.AuthReauthenticationException();
    }

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

/// Maps Google Sign-In failures (v7 [GoogleSignInException] or legacy
/// [PlatformException], e.g. ApiException: 10).
app_auth.AuthException? mapGoogleSignInError(Object error) {
  if (error is GoogleSignInException) {
    if (error.code == GoogleSignInExceptionCode.canceled) {
      return const app_auth.AuthCancelledException();
    }
    if (error.code == GoogleSignInExceptionCode.clientConfigurationError) {
      return const app_auth.AuthGoogleSignInConfigurationException();
    }
    return app_auth.AuthProviderException(
      app_auth.AuthProviderException.googleSignInFailedCode,
      code: error.code.name,
      description: error.description,
    );
  }

  if (error is! PlatformException) return null;

  if (error.code != 'sign_in_failed') {
    return app_auth.AuthProviderException(
      app_auth.AuthProviderException.googleSignInFailedCode,
      code: error.code,
      description: error.message,
    );
  }

  final message = error.message ?? '';
  if (_isGoogleDeveloperError(message)) {
    return const app_auth.AuthGoogleSignInConfigurationException();
  }

  return app_auth.AuthProviderException(
    app_auth.AuthProviderException.googleSignInFailedCode,
    code: error.code,
    description: error.message,
  );
}

bool _isGoogleDeveloperError(String message) {
  return message.contains(': 10') ||
      message.contains('10:') ||
      message.contains('ApiException: 10') ||
      message.contains('DEVELOPER_ERROR') ||
      message.contains('clientConfigurationError');
}
