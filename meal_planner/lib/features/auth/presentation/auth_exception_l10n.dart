import 'package:meal_planner/features/auth/domain/auth_exception.dart';
import 'package:meal_planner/l10n/app_localizations.dart';

String localizedAuthException(AuthException error, AppLocalizations l10n) {
  return switch (error) {
    AuthCaptchaException() => l10n.captchaFailed,
    AuthPasswordTooWeakException() => l10n.passwordTooWeak,
    AuthInvalidCurrentPasswordException() ||
    AuthReauthenticationException() => l10n.currentPasswordIncorrect,
    AuthSamePasswordException() => l10n.passwordSameAsCurrent,
    AuthProviderException(
      message: AuthProviderException.googleSignInFailedCode,
    ) =>
      l10n.googleSignInFailed,
    _ => error.message,
  };
}
