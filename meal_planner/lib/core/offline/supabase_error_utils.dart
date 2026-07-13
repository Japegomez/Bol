import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Returns true for auth/session failures that must not fall back to cache.
bool isAuthOrSessionError(Object error) {
  if (error is AuthException) return true;

  if (error is PostgrestException) {
    final code = error.code;
    if (code == '401' ||
        code == '403' ||
        code == 'PGRST301' ||
        code == '42501') {
      return true;
    }
    final message = error.message.toLowerCase();
    if (message.contains('jwt') ||
        message.contains('not authenticated') ||
        message.contains('invalid claim')) {
      return true;
    }
  }

  return false;
}

/// Returns true for connectivity/transport failures where cache fallback is OK.
bool isTransientNetworkError(Object error) {
  // Check for SocketException and HttpException via runtime type name
  // to maintain web compatibility (dart:io is not available on web)
  final errorType = error.runtimeType.toString();
  if (errorType == 'SocketException' ||
      errorType == 'HttpException' ||
      errorType == 'ClientException') {
    return true;
  }

  if (error is TimeoutException) return true;

  if (error is PostgrestException) {
    final code = error.code;
    if (code != null && code.startsWith('5')) return true;
  }

  final message = error.toString().toLowerCase();
  return message.contains('socket') ||
      message.contains('connection') ||
      message.contains('network') ||
      message.contains('timeout') ||
      message.contains('failed host lookup') ||
      message.contains('connection reset') ||
      message.contains('disconnected') ||
      message.contains('internet');
}

bool shouldFallbackToCache(Object error) {
  if (isAuthOrSessionError(error)) return false;
  return isTransientNetworkError(error);
}
