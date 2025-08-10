import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../env.dart';
import 'package:dio/dio.dart';

class MobileServerFlowAuthService {
  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  final FlutterSecureStorage _secure = const FlutterSecureStorage();
  final Dio _dio = Dio();

  static const _kAppToken = 'app_access_token';

  Future<void> signIn() async {
    final r = await _appAuth.authorize(AuthorizationRequest(
      Env.clientId,
      Env.redirectUri,
      discoveryUrl: '${Env.issuer}/.well-known/openid-configuration',
      scopes: Env.scopes,
      promptValues: ['login'],
    ));
    final code = r!.authorizationCode!;
    final verifier = r.codeVerifier!;
    final resp = await _dio.post('${Env.apiBase}/mobile/auth/code', data: {
      'code': code,
      'code_verifier': verifier,
      'redirect_uri': Env.redirectUri,
      'client_id': Env.clientId
    });
    final appToken = resp.data['app_access_token'] as String;
    await _secure.write(key: _kAppToken, value: appToken);
  }

  Future<String?> readAppToken() async {
    return _secure.read(key: _kAppToken);
  }

  Future<void> signOut() async {
    await _secure.delete(key: _kAppToken);
  }
}