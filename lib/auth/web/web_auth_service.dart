import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../env.dart';
import 'web_pkce.dart';

class WebAuthService {
  static const _kVerifier = 'pkce_code_verifier';
  static const _kAppToken = 'app_access_token';
  final Dio _dio = Dio();

  Future<String> buildAuthorizeUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final verifier = WebPkce.generateCodeVerifier();
    await prefs.setString(_kVerifier, verifier);
    final challenge = WebPkce.codeChallengeS256(verifier);
    final auth = Uri.parse('${Env.issuer}/protocol/openid-connect/auth').replace(queryParameters: {
      'client_id': Env.clientId,
      'redirect_uri': Env.webRedirectUri,
      'response_type': 'code',
      'scope': Env.scopes.join(' '),
      'code_challenge_method': 'S256',
      'code_challenge': challenge,
    });
    return auth.toString();
  }

  Future<void> completeLoginFromCallback(Uri currentUri) async {
    final code = currentUri.queryParameters['code'];
    if (code == null || code.isEmpty) {
      throw Exception('missing_code');
    }
    final prefs = await SharedPreferences.getInstance();
    final verifier = prefs.getString(_kVerifier);
    if (verifier == null || verifier.isEmpty) {
      throw Exception('missing_verifier');
    }
    final resp = await _dio.post('${Env.apiBase}/mobile/auth/code', data: {
      'code': code,
      'code_verifier': verifier,
      'redirect_uri': Env.webRedirectUri,
      'client_id': Env.clientId
    });
    final appToken = resp.data['app_access_token'] as String;
    await prefs.setString(_kAppToken, appToken);
    await prefs.remove(_kVerifier);
  }

  Future<String?> readAppToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kAppToken);
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAppToken);
  }
}