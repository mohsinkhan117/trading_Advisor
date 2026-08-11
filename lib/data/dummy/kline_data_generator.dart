import 'dart:math';
import 'package:k_chart_multiple/flutter_k_chart.dart';
import 'package:trading_advisor/core/models/coin_model.dart';

/// Offline fallback candle generator, used by [CoinChartPage] when the
/// CoinGecko chart request fails (rate limit, no connection, etc.) so the
/// chart still has something to show instead of an error screen.
class KlineDataGenerator {
  /// Builds candles via KLineEntity.fromJson, matching the standard k_chart
  /// data schema (open/close/high/low/vol/time). Verify these key names
  /// against your installed k_chart_multiple's fromJson implementation.
  static List<KLineEntity> generate(Coin coin, {int count = 150}) {
    final rand = Random(coin.symbol.hashCode);
    final volatility = coin.currentPrice < 1 ? 0.035 : 0.02;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    const stepMs = 3600 * 1000; // 1h candles

    double price = coin.currentPrice;
    final walked = <double>[price];
    for (int i = 0; i < count - 1; i++) {
      final drift = (rand.nextDouble() - 0.48) * volatility;
      price = price / (1 + drift);
      walked.add(price);
    }
    final closesOldestFirst = walked.reversed.toList();

    // The random walk above wiggles loosely around currentPrice and often
    // never reaches the coin's entry/target/invalidation levels. Those
    // levels drive the chart's trade-mark annotations, and the chart's
    // Y-axis is auto-scaled purely from candle high/low — a mark outside
    // that range simply doesn't render. Stretch the walk's amplitude
    // (anchored on the last candle, which stays pinned at currentPrice) so
    // every key level is comfortably inside the visible price range.
    final anchor = coin.currentPrice;
    final rawMin = closesOldestFirst.reduce(min);
    final rawMax = closesOldestFirst.reduce(max);
    final neededMin = [
      coin.invalidationLevel,
      coin.entryZoneLow,
      anchor * 0.95,
    ].reduce(min);
    final neededMax = [
      coin.exitTarget * 1.06, // headroom so the "Target" mark/label clears
      // the chart's own top price-axis label instead of colliding with it
      coin.entryZoneHigh,
      anchor * 1.05,
    ].reduce(max);

    double scale = 1.0;
    if (rawMin < anchor && neededMin < rawMin) {
      scale = max(scale, (neededMin - anchor) / (rawMin - anchor));
    }
    if (rawMax > anchor && neededMax > rawMax) {
      scale = max(scale, (neededMax - anchor) / (rawMax - anchor));
    }
    if (scale > 1.0) {
      for (int i = 0; i < closesOldestFirst.length; i++) {
        closesOldestFirst[i] = anchor + (closesOldestFirst[i] - anchor) * scale;
      }
    }

    final maps = <Map<String, dynamic>>[];
    double volume = coin.currentPrice < 1 ? 5000000 : 800000;
    for (int i = 0; i < closesOldestFirst.length; i++) {
      final open = i == 0 ? closesOldestFirst[i] * (1 - volatility / 2) : closesOldestFirst[i - 1];
      final close = closesOldestFirst[i];
      final high = max(open, close) * (1 + rand.nextDouble() * volatility / 2);
      final low = max(0.0001, min(open, close) * (1 - rand.nextDouble() * volatility / 2));
      volume = (volume * (1 + (rand.nextDouble() - 0.5) * 0.3)).abs();

      maps.add({
        'time': nowMs - (closesOldestFirst.length - i) * stepMs,
        'open': open,
        'high': high,
        'low': low,
        'close': close,
        'vol': volume,
      });
    }

    final datas = maps.map((m) => KLineEntity.fromJson(m)).toList();
    DataUtil.calculate(datas); // required — computes MA/indicators/probability
    return datas;
  }
}