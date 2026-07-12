import 'dart:async';
import 'dart:io';

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
  if (error is SocketException) return true;
  if (error is TimeoutException) return true;
  if (error is HttpException) return true;
  if (error.runtimeType.toString() == 'ClientException') return true;

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
      message.contains('connection reset');
}

bool shouldFallbackToCache(Object error) {
  if (isAuthOrSessionError(error)) return false;
  return isTransientNetworkError(error);
}
