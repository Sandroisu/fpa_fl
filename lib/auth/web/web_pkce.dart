import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class WebPkce {
  static String _base64UrlNoPad(List<int> bytes) {
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  static String generateCodeVerifier() {
    final rnd = Random.secure();
    final bytes = List<int>.generate(64, (_) => rnd.nextInt(256));
    return _base64UrlNoPad(bytes);
  }

  static String codeChallengeS256(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return _base64UrlNoPad(digest.bytes);
  }
}