import 'package:flutter/material.dart';
import 'package:trading_advisor/core/models/coin_model.dart';

class HomeViewModel extends ChangeNotifier {
  bool isLoading = false;

  final List<Coin> recommendedCoins = [
    Coin(
      symbol: 'BTC',
      name: 'Bitcoin',
      iconEmoji: '₿',
      iconUrl:
          'https://cdn.jsdelivr.net/npm/cryptocurrency-icons@0.18.1/128/color/btc.png',
      currentPrice: 62150.32,
      changePercent24h: 2.14,
      predictedPrice: 68500.00,
      targetDate: DateTime.now().add(const Duration(days: 10)),
      confidenceScore: 78,
      trend: CoinTrend.bullish,
      suggestedHoldingDays: 10,
      suggestedInvestmentPercent: 15,
      entryZoneLow: 61500,
      entryZoneHigh: 62800,
      exitTarget: 68500,
      invalidationLevel: 58900,
    ),
    Coin(
      symbol: 'ETH',
      name: 'Ethereum',
      iconEmoji: 'Ξ',
      iconUrl:
          'https://cdn.jsdelivr.net/npm/cryptocurrency-icons@0.18.1/128/color/eth.png',

      currentPrice: 3420.10,
      changePercent24h: -1.42,
      predictedPrice: 3180.00,
      targetDate: DateTime.now().add(const Duration(days: 6)),
      confidenceScore: 64,
      trend: CoinTrend.bearish,
      suggestedHoldingDays: 6,
      suggestedInvestmentPercent: 8,
      entryZoneLow: 3450,
      entryZoneHigh: 3520,
      exitTarget: 3180,
      invalidationLevel: 3600,
    ),
    Coin(
      symbol: 'SOL',
      name: 'Solana',
      iconEmoji: '◎',
      iconUrl:
          'https://cdn.jsdelivr.net/npm/cryptocurrency-icons@0.18.1/128/color/sol.png',

      currentPrice: 148.72,
      changePercent24h: 5.63,
      predictedPrice: 172.00,
      targetDate: DateTime.now().add(const Duration(days: 14)),
      confidenceScore: 71,
      trend: CoinTrend.bullish,
      suggestedHoldingDays: 14,
      suggestedInvestmentPercent: 10,
      entryZoneLow: 144,
      entryZoneHigh: 150,
      exitTarget: 172,
      invalidationLevel: 132,
    ),
    Coin(
      symbol: 'ADA',
      name: 'Cardano',
      iconEmoji: '₳',
      iconUrl:
          'https://cdn.jsdelivr.net/npm/cryptocurrency-icons@0.18.1/128/color/ada.png',

      currentPrice: 0.412,
      changePercent24h: 0.85,
      predictedPrice: 0.445,
      targetDate: DateTime.now().add(const Duration(days: 21)),
      confidenceScore: 55,
      trend: CoinTrend.neutral,
      suggestedHoldingDays: 21,
      suggestedInvestmentPercent: 5,
      entryZoneLow: 0.40,
      entryZoneHigh: 0.42,
      exitTarget: 0.445,
      invalidationLevel: 0.375,
    ),
    Coin(
      symbol: 'DOGE',
      name: 'Dogecoin',
      iconEmoji: 'Ð',
      iconUrl:
          'https://cdn.jsdelivr.net/npm/cryptocurrency-icons@0.18.1/128/color/doge.png',

      currentPrice: 0.1284,
      changePercent24h: 8.92,
      predictedPrice: 0.148,
      targetDate: DateTime.now().add(const Duration(days: 4)),
      confidenceScore: 42,
      trend: CoinTrend.bullish,
      suggestedHoldingDays: 4,
      suggestedInvestmentPercent: 3,
      entryZoneLow: 0.122,
      entryZoneHigh: 0.130,
      exitTarget: 0.148,
      invalidationLevel: 0.112,
    ),
  ];

  Coin? _selectedCoin;
  Coin? get selectedCoin => _selectedCoin;

  void selectCoin(Coin coin) {
    _selectedCoin = coin;
    notifyListeners();
  }

  Future<void> refresh() async {
    isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 600)); // simulate fetch
    isLoading = false;
    notifyListeners();
  }
}
