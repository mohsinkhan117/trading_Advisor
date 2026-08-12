import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:trading_advisor/core/config/env_config.dart';
import 'package:trading_advisor/core/models/coin_model.dart';
import 'package:trading_chart_flutter/trading_chart_flutter.dart';

class CoinApiService {
  static const _baseUrl = 'https://api.coingecko.com/api/v3';

  Map<String, String>? get _headers => EnvConfig.coinGeckoApiKey.isEmpty
      ? null
      : {'x-cg-demo-api-key': EnvConfig.coinGeckoApiKey};

  /// Fetches real market data and layers on dummy suggestion fields
  /// (target price, holding window, confidence) since the recommendation
  /// engine itself isn't built yet.
  Future<List<Coin>> fetchMarketCoins({int perPage = 50}) async {
    final uri = Uri.parse(
      '$_baseUrl/coins/markets'
      '?vs_currency=usd&order=market_cap_desc&per_page=$perPage&page=1'
      '&sparkline=false&price_change_percentage=24h',
    );

    final response = await http.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw Exception(
        'CoinGecko error ${response.statusCode}: ${response.body}',
      );
    }

    final List<dynamic> data = json.decode(response.body);
    return data
        .map((json) => _mapToCoin(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetches real historical price/volume data for [coinId] and buckets it
  /// into OHLCV candles for the chart. Uses `market_chart` (not `/ohlc`) so
  /// price and volume come from a single call at matching timestamps —
  /// mixing endpoints would mean merging two different granularities.
  Future<List<Candle>> fetchChartCandles(
    String coinId, {
    int days = 7,
    int bucketSize = 4,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/coins/$coinId/market_chart?vs_currency=usd&days=$days',
    );

    final response = await http.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw Exception(
        'CoinGecko error ${response.statusCode}: ${response.body}',
      );
    }

    final Map<String, dynamic> body = json.decode(response.body);
    final prices = (body['prices'] as List).cast<List<dynamic>>();
    final volumes = (body['total_volumes'] as List).cast<List<dynamic>>();
    if (prices.isEmpty) {
      throw Exception('CoinGecko returned no price history for $coinId');
    }

    final candles = <Candle>[];
    for (int i = 0; i < prices.length; i += bucketSize) {
      final end = min(i + bucketSize, prices.length);
      final bucket = prices
          .sublist(i, end)
          .map((p) => (p[1] as num).toDouble())
          .toList();
      final volBucket = volumes
          .sublist(i, min(end, volumes.length))
          .map((v) => (v[1] as num).toDouble())
          .toList();
      final totalVolume = volBucket.isEmpty
          ? 0.0
          : volBucket.reduce((a, b) => a + b);

      candles.add(
        Candle(
          // CoinGecko timestamps are milliseconds; Candle.time is seconds.
          time: (prices[i][0] as num).toInt() ~/ 1000,
          open: bucket.first,
          close: bucket.last,
          high: bucket.reduce(max),
          low: bucket.reduce(min),
          volume: totalVolume,
        ),
      );
    }

    return candles;
  }

  Coin _mapToCoin(Map<String, dynamic> json) {
    final currentPrice = (json['current_price'] as num).toDouble();
    final changeAmount = (json['price_change_24h'] as num?)?.toDouble() ?? 0;
    final change24h =
        (json['price_change_percentage_24h'] as num?)?.toDouble() ?? 0;

    // ── Dummy suggestion logic — replace with the real model later ──
    final isBullish = change24h >= 0;
    final projectedMovePercent =
        (change24h.abs().clamp(1, 15)) * (isBullish ? 1 : -1) * 1.4;
    final predictedPrice = currentPrice * (1 + projectedMovePercent / 100);
    final holdingDays = 3 + (change24h.abs().clamp(0, 20)).round();
    final confidence = (50 + change24h.abs() * 2).clamp(30, 92).round();

    return Coin(
      id: json['id'] as String,
      symbol: (json['symbol'] as String).toUpperCase(),
      name: json['name'] as String,
      iconUrl: json['image'] as String, // real logo, straight from CoinGecko
      iconEmoji: '●', // fallback glyph if image fails to load
      currentPrice: currentPrice,
      changeAmount24h: changeAmount,
      changePercent24h: change24h,
      predictedPrice: predictedPrice,
      targetDate: DateTime.now().add(Duration(days: holdingDays)),
      confidenceScore: confidence,
      trend: isBullish ? CoinTrend.bullish : CoinTrend.bearish,
      suggestedHoldingDays: holdingDays,
      suggestedInvestmentPercent: (confidence / 10).clamp(2, 20),
      entryZoneLow: currentPrice * 0.985,
      entryZoneHigh: currentPrice * 1.01,
      exitTarget: predictedPrice,
      invalidationLevel: currentPrice * (isBullish ? 0.93 : 1.07),
    );
  }
}
