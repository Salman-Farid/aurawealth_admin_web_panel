class ApiEndpoints {
  // Admin Authentication
  static const String adminLogin = '/admin/login';
  
  // Admin Dashboard
  static const String adminDashboard = '/admin/dashboard';
  
  // Gold Price Management
  static const String setPrice = '/admin/set-price';
  static const String getPrice = '/prices';
  
  // Transaction Management
  static String adminBuyCredit = '/admin/buy/credit';
  static String adminRedeemCode(String code) => '/admin/redeem-code?code=$code';
  static String adminMarkAsPaid(String txId) => '/admin/$txId/mark-as-paid';
  static String adminReject(String txId) => '/admin/$txId/reject';
  
  // Messaging
  static const String adminMessages = '/admin/messages';
  static String adminUserMessages(String userId) => '/admin/messages/$userId';
  static String adminReplyMessage(String userId) => '/admin/messages/$userId';
}
