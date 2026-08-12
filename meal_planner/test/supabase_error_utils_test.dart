import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/core/offline/supabase_error_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientException implements Exception {
  @override
  String toString() => 'ClientException: connection failed';
}

void main() {
  group('isAuthOrSessionError', () {
    test('is true for AuthException', () {
      expect(
        isAuthOrSessionError(const AuthException('session missing')),
        isTrue,
      );
    });

    test('is true for Postgrest 401/403/JWT codes', () {
      expect(
        isAuthOrSessionError(
          const PostgrestException(message: 'denied', code: '401'),
        ),
        isTrue,
      );
      expect(
        isAuthOrSessionError(
          const PostgrestException(message: 'denied', code: 'PGRST301'),
        ),
        isTrue,
      );
    });

    test('is true when Postgrest message mentions jwt', () {
      expect(
        isAuthOrSessionError(
          const PostgrestException(message: 'Invalid JWT', code: '400'),
        ),
        isTrue,
      );
    });

    test('is false for unrelated errors', () {
      expect(isAuthOrSessionError(Exception('boom')), isFalse);
    });
  });

  group('isTransientNetworkError', () {
    test('is true for TimeoutException', () {
      expect(isTransientNetworkError(TimeoutException('timed out')), isTrue);
    });

    test('is true for ClientException by type name', () {
      expect(isTransientNetworkError(ClientException()), isTrue);
    });

    test('is true for Postgrest 5xx', () {
      expect(
        isTransientNetworkError(
          const PostgrestException(message: 'unavailable', code: '503'),
        ),
        isTrue,
      );
    });

    test('is true when the message mentions network', () {
      expect(isTransientNetworkError(Exception('network unreachable')), isTrue);
    });

    test('is false for a generic application error', () {
      expect(isTransientNetworkError(Exception('validation failed')), isFalse);
    });
  });

  group('shouldFallbackToCache', () {
    test('is false for auth errors even if they look transient', () {
      expect(
        shouldFallbackToCache(const AuthException('not authenticated')),
        isFalse,
      );
    });

    test('is true for transient network errors', () {
      expect(shouldFallbackToCache(TimeoutException('timed out')), isTrue);
    });
  });
}
