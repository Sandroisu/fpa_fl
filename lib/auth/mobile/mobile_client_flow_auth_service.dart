import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../env.dart';

class MobileClientTokens {
  final String accessToken;
  final String refreshToken;
  final DateTime accessExpiry;
  const MobileClientTokens(this.accessToken, this.refreshToken, this.accessExpiry);
}

class MobileClientFlowAuthService {
  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  static const _kAt = 'kc_access';
  static const _kRt = 'kc_refresh';
  static const _kExp = 'kc_exp_ms';

  Future<MobileClientTokens?> load() async {
    final at = await _secure.read(key: _kAt);
    final rt = await _secure.read(key: _kRt);
    final ms = await _secure.read(key: _kExp);
    if (at == null || rt == null || ms == null) return null;
    return MobileClientTokens(at, rt, DateTime.fromMillisecondsSinceEpoch(int.parse(ms)));
  }

  Future<void> _save(MobileClientTokens t) async {
    await _secure.write(key: _kAt, value: t.accessToken);
    await _secure.write(key: _kRt, value: t.refreshToken);
    await _secure.write(key: _kExp, value: t.accessExpiry.millisecondsSinceEpoch.toString());
  }

  Future<MobileClientTokens> signIn() async {
    final r = await _appAuth.authorizeAndExchangeCode(AuthorizationTokenRequest(
      Env.clientId,
      Env.redirectUri,
      discoveryUrl: '${Env.issuer}/.well-known/openid-configuration',
      scopes: Env.scopes,
      promptValues: ['login'],
    ));
    final t = MobileClientTokens(
      r!.accessToken!,
      r.refreshToken!,
      r.accessTokenExpirationDateTime!,
    );
    await _save(t);
    return t;
  }

  Future<MobileClientTokens> refresh(MobileClientTokens cur) async {
    final r = await _appAuth.token(TokenRequest(
      Env.clientId,
      Env.redirectUri,
      discoveryUrl: '${Env.issuer}/.well-known/openid-configuration',
      refreshToken: cur.refreshToken,
      scopes: Env.scopes,
    ));
    final t = MobileClientTokens(
      r!.accessToken!,
      r.refreshToken ?? cur.refreshToken,
      r.accessTokenExpirationDateTime!,
    );
    await _save(t);
    return t;
  }

  Future<String> getValidAccessToken() async {
    final t = await load();
    if (t == null) return (await signIn()).accessToken;
    if (DateTime.now().isAfter(t.accessExpiry.subtract(const Duration(seconds: 30)))) {
      return (await refresh(t)).accessToken;
    }
    return t.accessToken;
  }

  Future<void> signOut() async {
    await _secure.delete(key: _kAt);
    await _secure.delete(key: _kRt);
    await _secure.delete(key: _kExp);
  }
}
