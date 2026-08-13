import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/features/auth/domain/password_policy.dart';

void main() {
  group('PasswordPolicy', () {
    test('rejects empty values', () {
      expect(PasswordPolicy.validate(null), PasswordPolicyError.empty);
      expect(PasswordPolicy.validate(''), PasswordPolicyError.empty);
    });

    test('rejects passwords shorter than 8 characters', () {
      expect(PasswordPolicy.validate('Ab1!x'), PasswordPolicyError.tooShort);
    });

    test('requires lowercase, uppercase, digit and symbol', () {
      expect(PasswordPolicy.validate('abcdefgh'), PasswordPolicyError.tooWeak);
      expect(PasswordPolicy.validate('ABCDEFGH'), PasswordPolicyError.tooWeak);
      expect(PasswordPolicy.validate('Abcdefgh'), PasswordPolicyError.tooWeak);
      expect(PasswordPolicy.validate('Abcdefg1'), PasswordPolicyError.tooWeak);
      expect(PasswordPolicy.validate('abcdef1!'), PasswordPolicyError.tooWeak);
      expect(PasswordPolicy.validate('ABCDEF1!'), PasswordPolicyError.tooWeak);
    });

    test('accepts a password that meets Supabase requirements', () {
      expect(PasswordPolicy.validate('Abcdef1!'), isNull);
    });
  });
}
