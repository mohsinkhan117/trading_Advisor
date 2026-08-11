import 'package:flutter/material.dart';
import 'package:trading_advisor/core/models/coin_model.dart';
import 'package:trading_advisor/core/theme/app_colors/app_colors.dart';
import 'package:trading_advisor/core/constants/sizes/sizes.dart';
import 'package:trading_advisor/data/dummy/kline_data_generator.dart';

class CoinChartPage extends StatefulWidget {
  final Coin coin;
  const CoinChartPage({super.key, required this.coin});

  @override
  State<CoinChartPage> createState() => _CoinChartPageState();
}

class _CoinChartPageState extends State<CoinChartPage> {
  late List<KLineEntity> _datas;
  late List<TradeMark> _tradeMarks;
  MainState _mainState = MainState.MA;
  final List<SecondaryState> _secondaryStates = [
    SecondaryState.MACD,
    SecondaryState.RSI,
  ];
  bool _volHidden = false;
  bool _showTradeMarks = true;
  double? _liveUpProbability;

  @override
  void initState() {
    super.initState();
    _datas = KlineDataGenerator.generate(widget.coin);
    _tradeMarks = KlineDataGenerator.tradeMarks(widget.coin, _datas);
  }

  @override
  Widget build(BuildContext context) {
    final coin = widget.coin;
    final gain = coin.expectedGainPercent;
    final trendColor = AppColors.priceChangeColor(gain);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              coin.symbol,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 6),
            Text(
              coin.name,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _PriceHeader(
            coin: coin,
            gain: gain,
            trendColor: trendColor,
            liveProbability: _liveUpProbability,
          ),
          const SizedBox(height: AppSizes.sm),
          Expanded(
            child: KChartWidget(
              _datas,
              ChartStyle(),
              ChartColors(),
              isTrendLine: false,
              mainState: _mainState,
              secondaryStates: _secondaryStates,
              volHidden: _volHidden,
              showNowPrice: true,
              fixedLength: coin.currentPrice < 1 ? 4 : 2,
              timeFormat: TimeFormat.YEAR_MONTH_DAY_WITH_HOUR,
              tradeMarks: _showTradeMarks ? _tradeMarks : const [],
              showTradeMarks: _showTradeMarks,
              onLoadMore: (isRightEdge) {
                // hook up pagination / older candle fetch here later
              },
              onMainGoingUp: (prob) {
                setState(() => _liveUpProbability = prob);
              },
            ),
          ),
          _IndicatorControls(
            mainState: _mainState,
            secondaryStates: _secondaryStates,
            volHidden: _volHidden,
            showTradeMarks: _showTradeMarks,
            onMainStateChanged: (state) => setState(() => _mainState = state),
            onSecondaryToggle: (state) {
              setState(() {
                _secondaryStates.contains(state)
                    ? _secondaryStates.remove(state)
                    : _secondaryStates.add(state);
              });
            },
            onVolToggle: () => setState(() => _volHidden = !_volHidden),
            onTradeMarksToggle: () =>
                setState(() => _showTradeMarks = !_showTradeMarks),
          ),
          _RecommendationFooter(coin: coin, trendColor: trendColor),
        ],
      ),
    );
  }
}

// ============== Price header ==============

class _PriceHeader extends StatelessWidget {
  final Coin coin;
  final double gain;
  final Color trendColor;
  final double? liveProbability;

  const _PriceHeader({
    required this.coin,
    required this.gain,
    required this.trendColor,
    required this.liveProbability,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.sm,
        AppSizes.md,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '\$${coin.currentPrice.toStringAsFixed(coin.currentPrice < 1 ? 4 : 2)}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.priceChangeSurface(gain),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${gain >= 0 ? '+' : ''}${gain.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: trendColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          if (liveProbability != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Model confidence',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${(liveProbability! * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: AppColors.priceChangeColor(liveProbability! - 0.5),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ============== Indicator controls ==============

class _IndicatorControls extends StatelessWidget {
  final MainState mainState;
  final List<SecondaryState> secondaryStates;
  final bool volHidden;
  final bool showTradeMarks;
  final ValueChanged<MainState> onMainStateChanged;
  final ValueChanged<SecondaryState> onSecondaryToggle;
  final VoidCallback onVolToggle;
  final VoidCallback onTradeMarksToggle;

  const _IndicatorControls({
    required this.mainState,
    required this.secondaryStates,
    required this.volHidden,
    required this.showTradeMarks,
    required this.onMainStateChanged,
    required this.onSecondaryToggle,
    required this.onVolToggle,
    required this.onTradeMarksToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        children: [
          _chip(
            'MA',
            mainState == MainState.MA,
            () => onMainStateChanged(MainState.MA),
          ),
          _chip(
            'BOLL',
            mainState == MainState.BOLL,
            () => onMainStateChanged(MainState.BOLL),
          ),
          const SizedBox(width: AppSizes.sm),
          Container(width: 1, color: AppColors.cardBorder),
          const SizedBox(width: AppSizes.sm),
          _chip(
            'MACD',
            secondaryStates.contains(SecondaryState.MACD),
            () => onSecondaryToggle(SecondaryState.MACD),
          ),
          _chip(
            'RSI',
            secondaryStates.contains(SecondaryState.RSI),
            () => onSecondaryToggle(SecondaryState.RSI),
          ),
          _chip(
            'KDJ',
            secondaryStates.contains(SecondaryState.KDJ),
            () => onSecondaryToggle(SecondaryState.KDJ),
          ),
          _chip('VOL', !volHidden, onVolToggle),
          _chip('Trades', showTradeMarks, onTradeMarksToggle),
        ],
      ),
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.xs),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            border: Border.all(
              color: active ? AppColors.primary : AppColors.cardBorder,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: active ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ============== Recommendation footer ==============

class _RecommendationFooter extends StatelessWidget {
  final Coin coin;
  final Color trendColor;

  const _RecommendationFooter({required this.coin, required this.trendColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.query_stats_rounded, size: 18, color: trendColor),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              'Entry \$${coin.entryZoneLow.toStringAsFixed(2)}–\$${coin.entryZoneHigh.toStringAsFixed(2)} · '
              'Target \$${coin.exitTarget.toStringAsFixed(2)} · '
              'Invalidation \$${coin.invalidationLevel.toStringAsFixed(2)} — not a guarantee',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
