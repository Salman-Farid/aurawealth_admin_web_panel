import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Auth Token
  Future<void> saveAuthToken(String token) async {
    await _prefs?.setString(AppConstants.authTokenKey, token);
  }

  String? getAuthToken() {
    return _prefs?.getString(AppConstants.authTokenKey);
  }

  Future<void> removeAuthToken() async {
    await _prefs?.remove(AppConstants.authTokenKey);
  }

  // User ID
  Future<void> saveUserId(String userId) async {
    await _prefs?.setString(AppConstants.userIdKey, userId);
  }

  String? getUserId() {
    return _prefs?.getString(AppConstants.userIdKey);
  }

  // User Email
  Future<void> saveUserEmail(String email) async {
    await _prefs?.setString(AppConstants.userEmailKey, email);
  }

  String? getUserEmail() {
    return _prefs?.getString(AppConstants.userEmailKey);
  }

  // Clear all data
  Future<void> clearAll() async {
    await _prefs?.clear();
  }

  // Check if user is authenticated
  bool get isAuthenticated => getAuthToken() != null;
}
