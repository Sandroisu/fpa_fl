import 'package:dio/dio.dart';
import '../env.dart';
import '../auth/web/web_auth_service.dart';

class WebApiClient {
  final Dio _dio = Dio(BaseOptions(baseUrl: Env.apiBase));
  final WebAuthService _auth = WebAuthService();

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