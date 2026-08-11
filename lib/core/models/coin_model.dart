enum CoinTrend { bullish, bearish, neutral }

class Coin {
  final String symbol;
  final String name;
  final String iconUrl;
  final String iconEmoji; // swap for a real asset/network image later
  final double currentPrice;
  final double changePercent24h;
  final double predictedPrice;
  final DateTime targetDate;
  final int confidenceScore; // 0-100
  final CoinTrend trend;
  final int suggestedHoldingDays;
  final double suggestedInvestmentPercent; // % of portfolio
  final double entryZoneLow;
  final double entryZoneHigh;
  final double exitTarget;
  final double invalidationLevel;

  const Coin({
    required this.symbol,
    required this.name,
    required this.iconUrl,
    required this.iconEmoji,
    required this.currentPrice,
    required this.changePercent24h,
    required this.predictedPrice,
    required this.targetDate,
    required this.confidenceScore,
    required this.trend,
    required this.suggestedHoldingDays,
    required this.suggestedInvestmentPercent,
    required this.entryZoneLow,
    required this.entryZoneHigh,
    required this.exitTarget,
    required this.invalidationLevel,
  });

  double get expectedGainPercent =>
      ((predictedPrice - currentPrice) / currentPrice) * 100;
}
