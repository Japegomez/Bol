import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/features/auth/data/auth_error_mapper.dart';
import 'package:meal_planner/features/auth/domain/auth_exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('maps invalid login credentials to friendly message', () {
    final error = mapAuthError(
      AuthApiException(
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
      AuthApiException(
        'Email not confirmed',
        statusCode: '400',
        code: 'email_not_confirmed',
      ),
    );

    expect(error, isA<AuthEmailNotConfirmedException>());
  });

  test('maps user already registered on sign up', () {
    final error = mapAuthError(
      AuthApiException(
        'User already registered',
        statusCode: '422',
        code: 'user_already_exists',
      ),
    );

    expect(error, isA<AuthUserAlreadyExistsException>());
  });

  test('maps Google sign_in_failed code 10 to configuration message', () {
    final error = mapAuthError(
      PlatformException(code: 'sign_in_failed', message: 'pc2.c: 10: '),
    );

    expect(error, isA<AuthGoogleSignInConfigurationException>());
  });
}
