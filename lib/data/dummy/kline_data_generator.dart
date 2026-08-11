import 'dart:math';
import 'package:trading_advisor/core/models/coin_model.dart';

class KlineDataGenerator {
  /// Builds candles via KLineEntity.fromJson, matching the standard k_chart
  /// data schema (open/close/high/low/vol/time). Verify these key names
  /// against your installed k_chart_multiple's fromJson implementation.
  static List<KLineEntity> generate(Coin coin, {int count = 150}) {
    final rand = Random(coin.symbol.hashCode);
    final volatility = coin.currentPrice < 1 ? 0.035 : 0.02;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    const stepMs = 3600 * 1000; // 1h candles

    final closesOldestFirst = <double>[];
    double price = coin.currentPrice;
    final walked = <double>[price];
    for (int i = 0; i < count - 1; i++) {
      final drift = (rand.nextDouble() - 0.48) * volatility;
      price = price / (1 + drift);
      walked.add(price);
    }
    closesOldestFirst.addAll(walked.reversed);

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

  /// Maps the coin's recommendation fields onto chart trade markers —
  /// entry zone, exit target, and invalidation level become visible
  /// annotations directly on the candles.
  static List<TradeMark> tradeMarks(Coin coin, List<KLineEntity> datas) {
    final lastIndex = datas.length - 1;
    return [
      TradeMark(
        index: lastIndex,
        price: (coin.entryZoneLow + coin.entryZoneHigh) / 2,
        side: TradeSide.long,
        action: TradeAction.entry,
        label: 'Entry',
      ),
      TradeMark(
        index: lastIndex,
        price: coin.exitTarget,
        side: TradeSide.long,
        action: TradeAction.tp,
        label: 'Target',
      ),
    ];
  }
}