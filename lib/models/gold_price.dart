class GoldPrice {
  final double price;
  final double bankSellPrice;
  final double exchangePrice;
  final double storeSellPrice;
  final DateTime createdAt;

  GoldPrice({
    required this.price,
    required this.bankSellPrice,
    required this.exchangePrice,
    required this.storeSellPrice,
    required this.createdAt,
  });

  factory GoldPrice.fromJson(Map<String, dynamic> json) {
    return GoldPrice(
      price: (json['price'] ?? 0).toDouble(),
      bankSellPrice: (json['bank_sell_price'] ?? 0).toDouble(),
      exchangePrice: (json['exchange_price'] ?? 0).toDouble(),
      storeSellPrice: (json['store_sell_price'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'price': price,
      'bank_sell_price': bankSellPrice,
      'exchange_price': exchangePrice,
      'store_sell_price': storeSellPrice,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
