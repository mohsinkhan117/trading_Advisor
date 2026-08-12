class CoinSearchResult {
  final String id;
  final String symbol;
  final String name;
  final String thumbUrl;
  final int? marketCapRank;

  const CoinSearchResult({
    required this.id,
    required this.symbol,
    required this.name,
    required this.thumbUrl,
    this.marketCapRank,
  });

  factory CoinSearchResult.fromJson(Map<String, dynamic> json) {
    return CoinSearchResult(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      thumbUrl: json['thumb'] as String? ?? '',
      marketCapRank: json['market_cap_rank'] as int?,
    );
  }
}
