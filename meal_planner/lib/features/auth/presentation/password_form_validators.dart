import 'package:meal_planner/features/auth/domain/password_policy.dart';
import 'package:meal_planner/l10n/app_localizations.dart';

String? validateNewPassword(String? value, AppLocalizations l10n) {
  return switch (PasswordPolicy.validate(value)) {
    PasswordPolicyError.empty => l10n.enterPasswordRegister,
    PasswordPolicyError.tooShort => l10n.passwordTooShort,
    PasswordPolicyError.tooWeak => l10n.passwordTooWeak,
    null => null,
  };
}
