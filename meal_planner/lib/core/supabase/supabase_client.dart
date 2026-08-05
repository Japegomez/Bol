import 'package:meal_planner/core/supabase/secure_gotrue_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

SupabaseClient get supabase => Supabase.instance.client;

abstract final class SupabaseConfig {
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      publishableKey: anonKey,
      authOptions: FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        localStorage: SecureLocalStorage(),
        pkceAsyncStorage: SecureGotrueAsyncStorage(),
        // Native Google/Apple use signInWithIdToken — not browser OAuth redirects.
        // Leaving this true makes supabase treat Google's iOS/Android return URLs
        // (often with `code=`) as auth callbacks, fail getSessionFromUrl, and
        // notifyException → kills authStateChanges until cold start.
        detectSessionInUri: false,
      ),
    );
  }
}
