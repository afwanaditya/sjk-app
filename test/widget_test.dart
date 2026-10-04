import 'package:flutter_test/flutter_test.dart';
import 'package:sjk_app/utils/validators.dart';

void main() {
  test('validateEmail', () {
    expect(validateEmail('a@b.co'), isNull);
    expect(validateEmail(''), isNotNull);
    expect(validateEmail('bukan-email'), isNotNull);
  });

  test('validateUsername', () {
    expect(validateUsername('user_01'), isNull);
    expect(validateUsername('User_01'), isNull); // otomatis lowercase
    expect(validateUsername('ab'), isNotNull);
    expect(validateUsername('a' * 21), isNotNull);
    expect(validateUsername('nama.user'), isNotNull);
  });

  test('validatePassword dan konfirmasi', () {
    expect(validatePassword('1234567'), isNotNull);
    expect(validatePassword('12345678'), isNull);
    expect(validatePasswordConfirmation('12345678', '12345678'), isNull);
    expect(validatePasswordConfirmation('12345679', '12345678'), isNotNull);
  });
}
