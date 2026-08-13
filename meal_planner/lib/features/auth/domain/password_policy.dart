enum PasswordPolicyError { empty, tooShort, tooWeak }

/// Client-side checks matching Supabase Auth "lowercase, uppercase, digits and symbols".
abstract final class PasswordPolicy {
  static const minLength = 8;

  static final _lowercase = RegExp(r'[a-z]');
  static final _uppercase = RegExp(r'[A-Z]');
  static final _digit = RegExp(r'[0-9]');

  /// ASCII symbols matching Supabase Auth / GoTrue `password_required_characters`.
  static final _symbol = RegExp(r'''[!@#$%^&*()_+=\[\]{};':"|<>?,./`~-]''');

  static PasswordPolicyError? validate(String? value) {
    if (value == null || value.isEmpty) {
      return PasswordPolicyError.empty;
    }
    if (value.length < minLength) {
      return PasswordPolicyError.tooShort;
    }
    if (!_lowercase.hasMatch(value) ||
        !_uppercase.hasMatch(value) ||
        !_digit.hasMatch(value) ||
        !_symbol.hasMatch(value)) {
      return PasswordPolicyError.tooWeak;
    }
    return null;
  }
}
