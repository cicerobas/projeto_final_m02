import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'package:projeto_final_m02/core/constants/api_constants.dart';

abstract final class PasswordHasher {
  static String hmacSha256(
    String password, {
    String secret = ApiConstants.hmacSecret,
  }) {
    final hmac = Hmac(sha256, utf8.encode(secret));
    return hmac.convert(utf8.encode(password)).toString();
  }
}
