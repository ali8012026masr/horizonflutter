import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/login_response.dart';
import 'secure_token_storage.dart';

class SessionManager extends ChangeNotifier {
  static const String _keyUserId = 'user_id';
  static const String _keyFullName = 'full_name';
  static const String _keyEmail = 'email';
  static const String _keyRole = 'role';
  static const String _keyStatus = 'status';
  static const String _keyVerificationStatus = 'verification_status';
  static const String _keyRejectionReason = 'rejection_reason';
  static const String _keyExpiresInSeconds = 'expires_in_seconds';

  static SessionManager? _instance;
  static SessionManager get instance => _instance ??= SessionManager._();

  SessionManager._();

  final SecureTokenStorage _tokenStorage = SecureTokenStorage();
  SharedPreferences? _prefs;

  int? _userId;
  String? _fullName;
  String? _email;
  String? _role;
  String? _status;
  String? _verificationStatus;
  String? _rejectionReason;
  String? _accessToken;
  String? _refreshToken;

  int? get userId => _userId;
  String? get fullName => _fullName;
  String? get email => _email;
  String? get role => _role;
  String? get status => _status;
  String? get verificationStatus => _verificationStatus;
  String? get rejectionReason => _rejectionReason;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  bool get isLoggedIn => _accessToken != null && _accessToken!.trim().isNotEmpty;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs?.getInt(_keyUserId);
    _fullName = _prefs?.getString(_keyFullName);
    _email = _prefs?.getString(_keyEmail);
    _role = _prefs?.getString(_keyRole);
    _status = _prefs?.getString(_keyStatus);
    _verificationStatus = _prefs?.getString(_keyVerificationStatus);
    _rejectionReason = _prefs?.getString(_keyRejectionReason);

    _accessToken = await _tokenStorage.getAccessToken();
    _refreshToken = await _tokenStorage.getRefreshToken();
    notifyListeners();
  }

  Future<void> save(LoginResponse response) async {
    _prefs ??= await SharedPreferences.getInstance();

    _userId = response.id;
    _fullName = response.fullName;
    _email = response.email;
    _role = response.role;
    _status = response.status;
    _verificationStatus = response.verificationStatus;
    _rejectionReason = response.rejectionReason;

    if (response.id != null) await _prefs!.setInt(_keyUserId, response.id!);
    if (response.fullName != null) await _prefs!.setString(_keyFullName, response.fullName!);
    if (response.email != null) await _prefs!.setString(_keyEmail, response.email!);
    if (response.role != null) await _prefs!.setString(_keyRole, response.role!);

    if (response.status != null) {
      await _prefs!.setString(_keyStatus, response.status!);
    } else {
      await _prefs!.remove(_keyStatus);
    }

    if (response.verificationStatus != null) {
      await _prefs!.setString(_keyVerificationStatus, response.verificationStatus!);
    } else {
      await _prefs!.remove(_keyVerificationStatus);
    }

    if (response.rejectionReason != null) {
      await _prefs!.setString(_keyRejectionReason, response.rejectionReason!);
    } else {
      await _prefs!.remove(_keyRejectionReason);
    }

    if (response.expiresInSeconds != null) {
      await _prefs!.setInt(_keyExpiresInSeconds, response.expiresInSeconds!);
    }

    if (response.accessToken != null && response.accessToken!.isNotEmpty) {
      _accessToken = response.accessToken;
      _refreshToken = response.refreshToken;
      await _tokenStorage.saveTokens(
        accessToken: response.accessToken!,
        refreshToken: response.refreshToken,
      );
    }

    notifyListeners();
  }

  Future<void> saveSession([
    LoginResponse? response,
  ]) async {
    if (response != null) {
      await save(response);
    }
  }

  Future<void> updateProfile({
    int? userId,
    String? email,
    String? role,
    String? fullName,
  }) async {
    _prefs ??= await SharedPreferences.getInstance();
    if (userId != null) {
      _userId = userId;
      await _prefs!.setInt(_keyUserId, userId);
    }
    if (email != null) {
      _email = email;
      await _prefs!.setString(_keyEmail, email);
    }
    if (role != null) {
      _role = role;
      await _prefs!.setString(_keyRole, role);
    }
    if (fullName != null) {
      _fullName = fullName;
      await _prefs!.setString(_keyFullName, fullName);
    }
    notifyListeners();
  }

  Future<void> updateAccessToken(String newAccessToken) async {
    if (newAccessToken.trim().isEmpty) return;
    _accessToken = newAccessToken;
    await _tokenStorage.updateAccessToken(newAccessToken);
    notifyListeners();
  }

  Future<void> updateStatusAndVerification({
    String? status,
    String? verificationStatus,
    String? rejectionReason,
  }) async {
    _prefs ??= await SharedPreferences.getInstance();

    if (status != null) {
      _status = status;
      await _prefs!.setString(_keyStatus, status);
    }
    if (verificationStatus != null) {
      _verificationStatus = verificationStatus;
      await _prefs!.setString(_keyVerificationStatus, verificationStatus);
    }
    if (rejectionReason != null) {
      _rejectionReason = rejectionReason;
      await _prefs!.setString(_keyRejectionReason, rejectionReason);
    }
    notifyListeners();
  }

  Future<void> clear() async {
    _userId = null;
    _fullName = null;
    _email = null;
    _role = null;
    _status = null;
    _verificationStatus = null;
    _rejectionReason = null;
    _accessToken = null;
    _refreshToken = null;

    if (_prefs != null) {
      await _prefs!.remove(_keyUserId);
      await _prefs!.remove(_keyFullName);
      await _prefs!.remove(_keyEmail);
      await _prefs!.remove(_keyRole);
      await _prefs!.remove(_keyStatus);
      await _prefs!.remove(_keyVerificationStatus);
      await _prefs!.remove(_keyRejectionReason);
      await _prefs!.remove(_keyExpiresInSeconds);
    }

    await _tokenStorage.clearTokens();
    notifyListeners();
  }
}
