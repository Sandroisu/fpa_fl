import 'package:dio/dio.dart';
import '../env.dart';
import '../auth/mobile_server_flow_auth_service.dart';

class MobileServerFlowApiClient {
  final Dio _dio;
  final MobileServerFlowAuthService _auth;

  MobileServerFlowApiClient(this._auth)
      : _dio = Dio(BaseOptions(baseUrl: Env.apiBase));

  Future<Map<String, dynamic>> getProfile() async {
    final token = await _auth.readAppToken();
    if (token == null || token.isEmpty) {
      throw Exception('no_app_token');
    }
    final r = await _dio.get(
      '/api/v1/profile',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return (r.data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> getSettings() async {
    final token = await _auth.readAppToken();
    if (token == null || token.isEmpty) {
      throw Exception('no_app_token');
    }
    final r = await _dio.get(
      '/api/v1/settings',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return (r.data as Map).cast<String, dynamic>();
  }
}