import 'package:k_chart_multiple/entity/trade_mark.dart';
import 'package:k_chart_multiple/flutter_k_chart.dart';
import 'package:trading_advisor/core/models/coin_model.dart';

/// Maps a coin's recommendation fields onto chart trade markers — entry
/// zone, exit target, and invalidation level — for either real or dummy
/// candle data (both use the same [KLineEntity]/index scheme).
class TradeMarksBuilder {
  TradeMarksBuilder._();

  /// Marks are spread across the last few candles rather than all stacked
  /// on the final one: the renderer draws each label to the right of its
  /// marker, so a mark sitting exactly at the last index gets its label
  /// clipped off the chart's right edge, and stacking all three on one
  /// candle makes them overlap the "now price" indicator.
  static List<TradeMark> build(Coin coin, List<KLineEntity> datas) {
    final lastIndex = datas.length - 1;
    int indexBefore(int offset) => (lastIndex - offset).clamp(0, lastIndex);

    return [
      TradeMark(
        index: indexBefore(18),
        price: (coin.entryZoneLow + coin.entryZoneHigh) / 2,
        side: TradeSide.long,
        action: TradeAction.entry,
        label: 'Entry',
      ),
      TradeMark(
        index: indexBefore(10),
        price: coin.exitTarget,
        side: TradeSide.long,
        action: TradeAction.tp,
        label: 'Target',
      ),
      TradeMark(
        index: indexBefore(9),
        price: coin.invalidationLevel,
        side: TradeSide.long,
        action: TradeAction.exitLoss,
        label: 'Invalidation',
      ),
    ];
  }
}
