import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meal_planner/features/auth/data/auth_error_mapper.dart';
import 'package:meal_planner/features/auth/domain/auth_exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('maps invalid login credentials to friendly message', () {
    final error = mapAuthError(
      const AuthApiException(
        'Invalid login credentials',
        statusCode: '400',
        code: 'invalid_credentials',
      ),
    );

    expect(error, isA<AuthInvalidCredentialsException>());
    expect(
      error.message,
      'Email o contraseña incorrectos. Comprueba los datos e inténtalo de nuevo.',
    );
  });

  test('maps email not confirmed', () {
    final error = mapAuthError(
      const AuthApiException(
        'Email not confirmed',
        statusCode: '400',
        code: 'email_not_confirmed',
      ),
    );

    expect(error, isA<AuthEmailNotConfirmedException>());
  });

  test('maps user already registered on sign up', () {
    final error = mapAuthError(
      const AuthApiException(
        'User already registered',
        statusCode: '422',
        code: 'user_already_exists',
      ),
    );

    expect(error, isA<AuthUserAlreadyExistsException>());
  });

  test('maps weak password', () {
    final error = mapAuthError(
      AuthWeakPasswordException(
        message: 'Password is known to be weak and easy to guess',
        statusCode: '422',
        reasons: ['characters'],
      ),
    );

    expect(error, isA<AuthPasswordTooWeakException>());
  });

  test('maps same password', () {
    final error = mapAuthError(
      const AuthApiException(
        'New password should be different from the old password.',
        statusCode: '422',
        code: 'same_password',
      ),
    );

    expect(error, isA<AuthSamePasswordException>());
  });

  test('maps reauthentication codes to a dedicated exception', () {
    final needed = mapAuthError(
      const AuthApiException(
        'Reauthentication needed',
        statusCode: '400',
        code: 'reauthentication_needed',
      ),
    );
    final notValid = mapAuthError(
      const AuthApiException(
        'Invalid login credentials',
        statusCode: '400',
        code: 'reauthentication_not_valid',
      ),
    );

    expect(needed, isA<AuthReauthenticationException>());
    expect(notValid, isA<AuthReauthenticationException>());
  });

  test(
    'maps current password required or invalid to current-password error',
    () {
      final requiredError = mapAuthError(
        const AuthApiException(
          'Current password required when setting new password.',
          statusCode: '400',
          code: 'current_password_required',
        ),
      );
      final invalidError = mapAuthError(
        const AuthApiException(
          'Current password required when setting new password.',
          statusCode: '400',
          code: 'current_password_invalid',
        ),
      );

      expect(requiredError, isA<AuthInvalidCurrentPasswordException>());
      expect(invalidError, isA<AuthInvalidCurrentPasswordException>());
    },
  );

  test('maps captcha_failed', () {
    final error = mapAuthError(
      const AuthApiException(
        'captcha protection: request disallowed (no captcha_token found)',
        statusCode: '400',
        code: 'captcha_failed',
      ),
    );

    expect(error, isA<AuthCaptchaException>());
  });

  test('maps Google sign_in_failed code 10 to configuration message', () {
    final error = mapAuthError(
      PlatformException(code: 'sign_in_failed', message: 'pc2.c: 10: '),
    );

    expect(error, isA<AuthGoogleSignInConfigurationException>());
  });

  test('maps GoogleSignInException canceled', () {
    final error = mapAuthError(
      const GoogleSignInException(code: GoogleSignInExceptionCode.canceled),
    );

    expect(error, isA<AuthCancelledException>());
  });

  test('maps GoogleSignInException client configuration', () {
    final error = mapAuthError(
      const GoogleSignInException(
        code: GoogleSignInExceptionCode.clientConfigurationError,
        description: 'SHA-1 fingerprint mismatch',
      ),
    );

    expect(error, isA<AuthGoogleSignInConfigurationException>());
  });

  test('maps generic GoogleSignInException to provider message', () {
    final error = mapAuthError(
      const GoogleSignInException(
        code: GoogleSignInExceptionCode.unknownError,
        description: 'Something went wrong with the provider',
      ),
    );

    expect(error, isA<AuthProviderException>());
    expect(
      error.message,
      'No se pudo iniciar sesión con Google. Inténtalo de nuevo.',
    );
  });
}
