import 'package:dio/dio.dart';
import '../env.dart';
import '../../auth/mobile/mobile_client_flow_auth_service.dart';

class MobileClientFlowApiClient {
  final Dio _dio;
  final MobileClientFlowAuthService _auth;

  MobileClientFlowApiClient(this._auth)
      : _dio = Dio(BaseOptions(baseUrl: Env.apiBase)) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _auth.getValidAccessToken();
        options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
      onError: (e, handler) async {
        if (e.response?.statusCode == 401) {
          try {
            final cur = await _auth.load();
            if (cur != null) {
              await _auth.refresh(cur);
              final token = await _auth.getValidAccessToken();
              e.requestOptions.headers['Authorization'] = 'Bearer $token';
              final clone = await _dio.fetch(e.requestOptions);
              handler.resolve(clone);
              return;
            }
          } catch (_) {}
        }
        handler.next(e);
      },
    ));
  }

  Future<Map<String, dynamic>> getProfile() async {
    final r = await _dio.get('/api/v1/profile');
    return (r.data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> getSettings() async {
    final r = await _dio.get('/api/v1/settings');
    return (r.data as Map).cast<String, dynamic>();
  }
}
