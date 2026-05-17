// ignore_for_file: avoid_print

import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/admin_fcm_service.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final ApiService _apiService = ApiService();
  final StorageService _storage = StorageService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isAuthenticated = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  void checkAuthStatus() {
    isAuthenticated.value = _storage.isAuthenticated;
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('[Auth] Login started for: $email');
      final response = await _apiService.adminLogin(email, password);
      print('[Auth] Login response keys: ${response.keys.toList()}');

      final token = response['access_token'];
      if (token != null) {
        print('[Auth] Access token received; saving auth state');
        await _storage.saveAuthToken(token);
        await _storage.saveUserEmail(email);
        isAuthenticated.value = true;
        print('[Auth] Auth state saved. Calling initAdminFCM()');
        await initAdminFCM();
        print('[Auth] initAdminFCM() completed. Navigating to dashboard');

        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        print('[Auth] Login response missing access_token: $response');
        throw Exception('Invalid response from server');
      }
    } catch (e, stackTrace) {
      print('[Auth] Login failed or post-login setup failed: $e');
      print('[Auth] Login stack trace: $stackTrace');
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> initAdminFCM() async {
    try {
      print('[Auth] initAdminFCM() started');
      await AdminFcmService.initialize();
      print('[Auth] initAdminFCM() finished successfully');
    } catch (e, stackTrace) {
      print('[Auth] initAdminFCM() threw an exception: $e');
      print('[Auth] initAdminFCM() stack trace: $stackTrace');
    }
  }

  Future<void> logout() async {
    await _storage.clearAll();
    isAuthenticated.value = false;
    Get.offAllNamed(AppRoutes.login);
  }
}
