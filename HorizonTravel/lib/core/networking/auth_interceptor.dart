import 'package:dio/dio.dart';
import '../storage/session_manager.dart';

typedef SessionExpiredCallback = void Function();

class AuthInterceptor extends Interceptor {
  static SessionExpiredCallback? onSessionExpired;

  final SessionManager _sessionManager;

  AuthInterceptor({SessionManager? sessionManager})
      : _sessionManager = sessionManager ?? SessionManager.instance;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final path = options.path;
    final isPublicAuth = path.contains('/auth/login') ||
        path.contains('/auth/register/') ||
        path.contains('/auth/forgot-password') ||
        path.contains('/auth/reset-password');

    if (!isPublicAuth && _sessionManager.isLoggedIn) {
      final token = _sessionManager.accessToken;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      final refreshToken = _sessionManager.refreshToken;
      if (refreshToken != null && refreshToken.isNotEmpty) {
        options.headers['x-refresh-token'] = refreshToken;
      }
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Read refreshed access token returned in headers by backend
    final refreshedToken = response.headers.value('x-access-token');
    if (refreshedToken != null && refreshedToken.trim().isNotEmpty) {
      _sessionManager.updateAccessToken(refreshedToken.trim());
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final path = err.requestOptions.path;
    final isPublicAuth = path.contains('/auth/login') ||
        path.contains('/auth/register/') ||
        path.contains('/auth/forgot-password') ||
        path.contains('/auth/reset-password');

    if (err.response?.statusCode == 401 && !isPublicAuth) {
      _sessionManager.clear();
      onSessionExpired?.call();
    }

    handler.next(err);
  }
}
