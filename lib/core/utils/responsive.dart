import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

enum DeviceType { mobile, tablet, desktop }

class Responsive {
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < AppConstants.mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < AppConstants.desktopBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }
  
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }
  
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }
  
  static bool isDesktop(BuildContext context) {
    return getDeviceType(context) == DeviceType.desktop;
  }
  
  static double getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
  
  static double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
  
  // Adaptive value based on screen size
  static T adaptive<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? desktop;
      case DeviceType.desktop:
        return desktop;
    }
  }
  
  // Get sidebar width based on device
  static double getSidebarWidth(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return 0; // Use drawer on mobile
      case DeviceType.tablet:
        return 70; // Collapsed sidebar on tablet
      case DeviceType.desktop:
        return 250; // Full sidebar on desktop
    }
  }
  
  // Get grid column count based on device
  static int getGridColumnCount(BuildContext context, {int? maxColumns}) {
    final width = getWidth(context);
    int columns;
    
    if (width < AppConstants.mobileBreakpoint) {
      columns = 1;
    } else if (width < AppConstants.desktopBreakpoint) {
      columns = 2;
    } else {
      columns = maxColumns ?? 4;
    }
    
    return columns;
  }
}
