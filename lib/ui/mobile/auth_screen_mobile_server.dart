import 'package:flutter/material.dart';
import '../../auth/mobile/mobile_server_flow_auth_service.dart';
import '../../api/api_client_mobile_server_flow.dart';
import '../shared/host_screen.dart';

class AuthScreenMobileServer extends StatefulWidget {
  const AuthScreenMobileServer({super.key});
  @override
  State<AuthScreenMobileServer> createState() => _AuthScreenMobileServerState();
}

class _AuthScreenMobileServerState extends State<AuthScreenMobileServer> {
  final _auth = MobileServerFlowAuthService();
  late final _api = MobileServerFlowApiClient(_auth);
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _auth.signIn();
      await _api.getProfile();
      await _api.getSettings();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/host');
    } catch (e) {
      setState(() {
        _error = '$e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Авторизация')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Войдите через Keycloak', textAlign: TextAlign.center),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading ? null : _login,
                    child: _loading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Войти'),
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(_error!, style: const TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}