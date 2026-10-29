import 'package:flutter_test/flutter_test.dart';

import 'package:projeto_final_m02/core/security/password_hasher.dart';

void main() {
  test('PasswordHasher gera o HMAC-SHA256 da senha em hexadecimal', () {
    expect(
      PasswordHasher.hmacSha256('senha123'),
      'efd54f5b3b4ef07df2db8707b4606f49567d2be508316048ca07b6b6edebf681',
    );
  });
}
