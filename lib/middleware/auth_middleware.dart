import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/storage_service.dart';
import '../routes/app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final storage = StorageService();
    if (!storage.isAuthenticated) {
      return RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}
