import 'package:flutter_test/flutter_test.dart';
import 'package:lifeflow/features/auth/presentation/auth_form_helpers.dart';

void main() {
  group('AuthValidators', () {
    test('email', () {
      expect(AuthValidators.email(''), isNotNull);
      expect(AuthValidators.email('not-an-email'), isNotNull);
      expect(AuthValidators.email(' student@ruh.ac.lk '), isNull);
    });

    test('new password needs at least 6 characters', () {
      expect(AuthValidators.newPassword('12345'), isNotNull);
      expect(AuthValidators.newPassword('123456'), isNull);
    });

    test('name must not be blank', () {
      expect(AuthValidators.name('   '), isNotNull);
      expect(AuthValidators.name('Dulsara'), isNull);
    });
  });
}
