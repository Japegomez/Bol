import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/supabase/supabase_client.dart';
import 'package:meal_planner/core/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ModerationResult {
  const ModerationResult({
    required this.allowed,
    this.reasons = const [],
  });

  final bool allowed;
  final List<String> reasons;
}

class PhotoModerationException implements Exception {
  PhotoModerationException(this.message);

  final String message;

  @override
  String toString() => message;
}

const _genericModerationFailure =
    'No se pudo comprobar la imagen. Inténtalo de nuevo.';

class PhotoModerationService {
  Future<ModerationResult> check(Uint8List bytes) async {
    try {
      final response = await supabase.functions
          .invoke(
            'moderate-image',
            body: {'image': base64Encode(bytes)},
          )
          .timeout(const Duration(seconds: 30));

      if (response.status != 200) {
        final detail = _extractErrorDetail(response.data);
        log.w('Photo moderation HTTP ${response.status}: $detail');
        throw PhotoModerationException(
          _userFacingModerationMessage(detail),
        );
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw PhotoModerationException(_genericModerationFailure);
      }

      final error = data['error'];
      if (error != null) {
        final detail = _extractErrorDetail(data);
        log.w('Photo moderation error response: $detail');
        throw PhotoModerationException(
          _userFacingModerationMessage(detail),
        );
      }

      return ModerationResult(
        allowed: data['allowed'] as bool? ?? false,
        reasons: (data['reasons'] as List?)?.cast<String>() ?? const [],
      );
    } on FunctionException catch (error) {
      final detail = _extractErrorDetail(error.details);
      log.w(
        'Photo moderation function exception (${error.status})',
        error: error,
      );
      throw PhotoModerationException(
        _userFacingModerationMessage(detail),
      );
    } catch (error) {
      log.w('Photo moderation unexpected error', error: error);
      throw PhotoModerationException(_genericModerationFailure);
    }
  }
}

final photoModerationServiceProvider = Provider<PhotoModerationService>((ref) {
  return PhotoModerationService();
});

String? _extractErrorDetail(dynamic data) {
  if (data is! Map) return null;
  final detail = data['detail'];
  if (detail is String && detail.isNotEmpty) {
    return detail;
  }
  return null;
}

bool _isConfigurationDetail(String detail) {
  final lower = detail.toLowerCase();
  return lower.contains('billing') ||
      lower.contains('api key') ||
      lower.contains('google_vision_api_key') ||
      lower.contains('has not been used') ||
      lower.contains('is disabled') ||
      lower.contains('referer') ||
      lower.contains('api_key_http_referrer') ||
      lower.contains('moderation not configured');
}

String _userFacingModerationMessage(String? detail) {
  if (detail == null || detail.isEmpty) {
    return _genericModerationFailure;
  }
  if (_isConfigurationDetail(detail)) {
    return _genericModerationFailure;
  }
  return detail;
}
