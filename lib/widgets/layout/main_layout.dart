import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive.dart';
import '../../routes/app_routes.dart';
import '../../services/storage_service.dart';
import 'sidebar_menu.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String title;

  const MainLayout({
    Key? key,
    required this.child,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: isMobile
            ? null
            : (isTablet
                ? IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  )
                : null),
        actions: [
          // Profile & Logout
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: PopupMenuButton<String>(
              offset: Offset(0, 50),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  SizedBox(width: 8),
                  if (!isMobile) ...[
                    Text(
                      StorageService().getUserEmail() ?? 'Admin',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down, color: AppColors.textPrimary),
                  ],
                ],
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(Icons.person_outline, size: 20),
                      SizedBox(width: 8),
                      Text('Profile'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Logout', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'logout') {
                  authController.logout();
                }
              },
            ),
          ),
        ],
      ),
      drawer: isMobile || isTablet ? Drawer(child: SidebarMenu()) : null,
      body: Row(
        children: [
          // Sidebar for Desktop
          if (!isMobile && !isTablet)
            Container(
              width: Responsive.getSidebarWidth(context),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(
                  right: BorderSide(color: AppColors.grey200, width: 1),
                ),
              ),
              child: SidebarMenu(),
            ),
          
          // Main Content
          Expanded(
            child: Container(
              color: AppColors.background,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
