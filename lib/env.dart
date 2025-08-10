import 'package:flutter/foundation.dart' show kIsWeb;

class Env {
  static const String issuer = 'https://auth.example.wrs/realms/wrs';
  static const String clientId = 'wrs-mobile';
  static const List<String> scopes = ['openid', 'profile', 'offline_access'];
  static const String mobileRedirectUri = 'ru.mobiledimension.wrs://oidc-callback';
  static String get webRedirectUri => '${Uri.base.origin}/auth-callback';
  static const String apiBase = 'https://api.example.wrs';
  static String get redirectUri => kIsWeb ? webRedirectUri : mobileRedirectUri;
}