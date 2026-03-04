class DashboardStats {
  final int totalUsers;
  final double totalGoldHoldings;
  final int totalTransactions;
  final int totalBuyTransactions;
  final int totalSellTransactions;
  final int pendingTransactions;
  final double totalRevenue;

  DashboardStats({
    required this.totalUsers,
    required this.totalGoldHoldings,
    required this.totalTransactions,
    required this.totalBuyTransactions,
    required this.totalSellTransactions,
    required this.pendingTransactions,
    required this.totalRevenue,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalUsers: json['total_users'] ?? 0,
      totalGoldHoldings: (json['total_gold_holdings'] ?? 0).toDouble(),
      totalTransactions: json['total_transactions'] ?? 0,
      totalBuyTransactions: json['total_buy_transactions'] ?? 0,
      totalSellTransactions: json['total_sell_transactions'] ?? 0,
      pendingTransactions: json['pending_transactions'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_users': totalUsers,
      'total_gold_holdings': totalGoldHoldings,
      'total_transactions': totalTransactions,
      'total_buy_transactions': totalBuyTransactions,
      'total_sell_transactions': totalSellTransactions,
      'pending_transactions': pendingTransactions,
      'total_revenue': totalRevenue,
    };
  }
}
