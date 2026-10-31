import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static const String emulatorBaseUrl = 'http://10.0.2.2:58080/api/';
  static const String lanBaseUrl = 'http://10.38.229.21:58080/api/';
  static const String localhostBaseUrl = 'http://localhost:58080/api/';
  static const String productionBaseUrl = 'https://api.horizontravel.example.com/api/';

  static String _customBaseUrl = '';

  static void setCustomBaseUrl(String url) {
    _customBaseUrl = url.trim();
  }

  static String get baseUrl {
    if (_customBaseUrl.isNotEmpty) {
      return _customBaseUrl.endsWith('/') ? _customBaseUrl : '$_customBaseUrl/';
    }
    if (kIsWeb) {
      return localhostBaseUrl;
    }
    if (Platform.isAndroid) {
      return emulatorBaseUrl;
    }
    return localhostBaseUrl;
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}
