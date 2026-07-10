import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/supabase/supabase_client.dart';

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

class PhotoModerationService {
  Future<ModerationResult> check(Uint8List bytes) async {
    final response = await supabase.functions.invoke(
      'moderate-image',
      body: {'image': base64Encode(bytes)},
    );

    if (response.status != 200) {
      final detail = _extractErrorDetail(response.data);
      throw PhotoModerationException(
        detail ?? 'No se pudo comprobar la imagen. Inténtalo de nuevo.',
      );
    }

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw PhotoModerationException('No se pudo comprobar la imagen.');
    }

    final error = data['error'];
    if (error != null) {
      throw PhotoModerationException(
        _extractErrorDetail(data) ??
            'No se pudo comprobar la imagen. Inténtalo de nuevo.',
      );
    }

    return ModerationResult(
      allowed: data['allowed'] as bool? ?? false,
      reasons: (data['reasons'] as List?)?.cast<String>() ?? const [],
    );
  }
}

final photoModerationServiceProvider = Provider<PhotoModerationService>((ref) {
  return PhotoModerationService();
});

String? _extractErrorDetail(dynamic data) {
  if (data is! Map) return null;
  final detail = data['detail'];
  if (detail is String && detail.isNotEmpty) {
    if (detail.contains('billing')) {
      return 'La moderación de imágenes no está disponible: activa facturación en Google Cloud Vision.';
    }
    if (detail.contains('API key not valid') ||
        detail.contains('invalid API key')) {
      return 'Clave de Google Vision inválida. Revisa GOOGLE_VISION_API_KEY en Supabase.';
    }
    if (detail.contains('has not been used') ||
        detail.contains('is disabled')) {
      return 'Activa Cloud Vision API en tu proyecto de Google Cloud.';
    }
    if (detail.contains('referer') || detail.contains('API_KEY_HTTP_REFERRER')) {
      return 'La API key tiene restricción de referrer; quítala o usa "Ninguna" para llamadas desde servidor.';
    }
    return detail;
  }
  return null;
}
