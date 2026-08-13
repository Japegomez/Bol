/// Runtime configuration via --dart-define (CI/Codemagic) or launch args.
abstract final class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const sentryDsn = String.fromEnvironment('SENTRY_DSN');
  static const googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
  );
  static const googleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
  );
  static const turnstileSiteKey = String.fromEnvironment('TURNSTILE_SITE_KEY');

  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static bool get hasTurnstile => turnstileSiteKey.isNotEmpty;

  static bool get hasSentry => sentryDsn.isNotEmpty;

  static bool get hasGoogleSignIn => googleWebClientId.isNotEmpty;

  static bool get isProduction => const bool.fromEnvironment('dart.vm.product');
}
