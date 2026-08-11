import 'package:flutter/material.dart';
import 'package:trading_advisor/core/models/coin_model.dart';
import 'package:trading_advisor/services/coin_api_service.dart';

class HomeViewModel extends ChangeNotifier {
  final CoinApiService _api = CoinApiService();

  bool isLoading = false;
  String? error;

  /// Full market list (market-cap order, as returned by the API) — feeds
  /// the "Market" section.
  List<Coin> marketCoins = [];

  /// Top movers by absolute 24h change — feeds the "Recommended Coins" strip.
  List<Coin> recommendedCoins = [];

  Coin? _selectedCoin;
  Coin? get selectedCoin => _selectedCoin;

  HomeViewModel() {
    _loadCoins();
  }

  void selectCoin(Coin coin) {
    _selectedCoin = coin;
    notifyListeners();
  }

  Future<void> _loadCoins() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final coins = await _api.fetchMarketCoins(perPage: 50);
      marketCoins = coins;
      recommendedCoins = (List.of(coins)..sort(
            (a, b) => b.changePercent24h.abs().compareTo(
              a.changePercent24h.abs(),
            ),
          ))
          .take(8)
          .toList();
    } catch (e) {
      error = 'Could not load market data: $e';
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => _loadCoins();
}
