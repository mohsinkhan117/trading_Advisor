import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:trading_advisor/core/models/coin_model.dart';
import 'package:trading_advisor/core/theme/app_colors/app_colors.dart';
import 'package:trading_advisor/core/theme/context_theme_ext.dart';
import 'package:trading_advisor/core/constants/sizes/sizes.dart';
import 'package:trading_advisor/services/coin_api_service.dart';
import 'package:trading_chart_flutter/trading_chart_flutter.dart';

enum TradeSide { buy, sell }

class CoinChartPage extends StatefulWidget {
  final Coin coin;
  const CoinChartPage({super.key, required this.coin});

  @override
  State<CoinChartPage> createState() => _CoinChartPageState();
}

class _CoinChartPageState extends State<CoinChartPage> {
  final CoinApiService _api = CoinApiService();
  final ChartController _controller = ChartController();
  final Random _rand = Random();
  final TextEditingController _amountController = TextEditingController(
    text: '100',
  );

  List<Candle> _candles = [];
  double? _livePrice;
  Timer? _liveTimer;
  bool _isLoading = true;
  bool _showVolume = true;
  bool _isLive = false;
  String? _error;
  TradeSide _tradeSide = TradeSide.buy;

  @override
  void initState() {
    super.initState();
    _loadChart();
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    _controller.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadChart() async {
    _liveTimer?.cancel();
    setState(() {
      _isLoading = true;
      _error = null;
      _isLive = false;
    });

    try {
      final candles = await _api.fetchChartCandles(widget.coin.id);
      if (!mounted) return;
      setState(() {
        _candles = candles;
        _livePrice = candles.isNotEmpty
            ? candles.last.close
            : widget.coin.currentPrice;
        _isLoading = false;
      });
      _controller.setData(candles);
      _startLiveTicks();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load chart data: $e';
        _isLoading = false;
      });
    }
  }

  void _startLiveTicks() {
    if (_candles.isEmpty) return;
    setState(() => _isLive = true);

    _liveTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted || _candles.isEmpty) return;

      final last = _candles.last;
      final volatility = last.close < 1 ? 0.006 : 0.0025;
      final drift = (_rand.nextDouble() - 0.5) * volatility;
      final newPrice = max(0.0001, last.close * (1 + drift));

      final updated = Candle(
        time: last.time,
        open: last.open,
        high: max(last.high, newPrice),
        low: min(last.low, newPrice),
        close: newPrice,
        volume: last.volume,
      );

      setState(() {
        _candles = [..._candles.sublist(0, _candles.length - 1), updated];
        _livePrice = newPrice;
      });
      _controller.upsert(updated);
    });
  }

  void _handleTrade(Coin coin, double livePrice) {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final qty = amount > 0 ? amount / livePrice : 0;
    final verb = _tradeSide == TradeSide.buy ? 'Bought' : 'Sold';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$verb ${qty.toStringAsFixed(qty < 1 ? 6 : 4)} ${coin.symbol} '
          '(\$${amount.toStringAsFixed(2)}) — dummy order, not executed',
        ),
        backgroundColor: _tradeSide == TradeSide.buy
            ? AppColors.bullish
            : AppColors.bearish,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coin = widget.coin;
    final livePrice = _livePrice ?? coin.currentPrice;
    final gain =
        ((livePrice - coin.currentPrice) / coin.currentPrice * 100) +
        coin.changePercent24h;
    final trendColor = AppColors.priceChangeColor(gain);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 48,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              coin.symbol,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(width: 5),
            Text(
              coin.name,
              style: TextStyle(
                fontSize: 11,
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            iconSize: 20,
            icon: Icon(
              _showVolume ? Icons.bar_chart_rounded : Icons.bar_chart_outlined,
            ),
            onPressed: () => setState(() => _showVolume = !_showVolume),
            tooltip: _showVolume ? 'Hide volume' : 'Show volume',
          ),
          IconButton(
            iconSize: 20,
            icon: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
            onPressed: _isLoading ? null : _loadChart,
            tooltip: 'Refresh chart',
          ),
        ],
      ),
      body: _buildBody(coin, livePrice, gain, trendColor),
      bottomNavigationBar:
          (_isLoading && _candles.isEmpty) ||
              (_error != null && _candles.isEmpty)
          ? null
          : _TradeActionBar(
              coin: coin,
              livePrice: livePrice,
              side: _tradeSide,
              amountController: _amountController,
              onSideChanged: (side) => setState(() => _tradeSide = side),
              onSubmit: () => _handleTrade(coin, livePrice),
            ),
    );
  }

  Widget _buildBody(
    Coin coin,
    double livePrice,
    double gain,
    Color trendColor,
  ) {
    if (_isLoading && _candles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _candles.isEmpty) {
      return _ChartErrorState(message: _error!, onRetry: _loadChart);
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      children: [
        _PriceHeader(
          livePrice: livePrice,
          gain: gain,
          trendColor: trendColor,
          isLive: _isLive,
        ),
        const SizedBox(height: AppSizes.xs),
        SizedBox(
          height: 280,
          child: InteractiveTradingChart(
            candles: _candles,
            controller: _controller,
            theme: ChartTheme.dark,
            showVolume: _showVolume,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        _AiParametersPanel(
          coin: coin,
          livePrice: livePrice,
          trendColor: trendColor,
        ),
        const SizedBox(height: AppSizes.sm),
        _TradePlanPanel(coin: coin),
        const SizedBox(height: AppSizes.xs),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: Text(
            'AI-generated signal, not financial advice. Not auto-executed.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.7),
              fontSize: 10,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.sm),
      ],
    );
  }
}

// ============== Error state ==============

class _ChartErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ChartErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 36,
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

// ============== Price header ==============

class _PriceHeader extends StatelessWidget {
  final double livePrice;
  final double gain;
  final Color trendColor;
  final bool isLive;

  const _PriceHeader({
    required this.livePrice,
    required this.gain,
    required this.trendColor,
    required this.isLive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.xs,
        AppSizes.md,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              '\$${livePrice.toStringAsFixed(livePrice < 1 ? 4 : 2)}',
              key: ValueKey(livePrice),
              style: TextStyle(
                color: context.colors.onSurface,
                fontSize: 21,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.xs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: trendColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${gain >= 0 ? '+' : ''}${gain.toStringAsFixed(2)}%',
              style: TextStyle(
                // trendColor is always primary (bullish) or error (bearish),
                // and onPrimary/onError both resolve to white in this theme.
                color: context.colors.onPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(),
          if (isLive)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LivePulseDot(),
                const SizedBox(width: 4),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    color: AppColors.bullish,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _LivePulseDot extends StatefulWidget {
  @override
  State<_LivePulseDot> createState() => _LivePulseDotState();
}

class _LivePulseDotState extends State<_LivePulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.3, end: 1.0).animate(_controller),
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          color: AppColors.bullish,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ============== AI parameters panel ==============

class _AiParametersPanel extends StatelessWidget {
  final Coin coin;
  final double livePrice;
  final Color trendColor;

  const _AiParametersPanel({
    required this.coin,
    required this.livePrice,
    required this.trendColor,
  });

  @override
  Widget build(BuildContext context) {
    final confidence = coin.confidenceScore;
    final signal = _tier(confidence, 'Strong', 'Moderate', 'Weak');
    final riskSpreadPercent =
        ((coin.entryZoneHigh - coin.invalidationLevel).abs() /
            coin.currentPrice) *
        100;
    final risk = riskSpreadPercent >= 12
        ? _Tier('High', AppColors.bearish)
        : riskSpreadPercent >= 6
        ? _Tier('Medium', AppColors.warning)
        : _Tier('Low', AppColors.bullish);
    final distanceToTargetPercent =
        ((coin.predictedPrice - livePrice) / livePrice) * 100;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology_rounded,
                size: 13,
                color: context.colors.primary,
              ),
              const SizedBox(width: 5),
              Text(
                'AI ANALYSIS',
                style: TextStyle(
                  color: context.colors.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Confidence in target',
                style: TextStyle(
                  color: context.colors.onSurface,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$confidence%',
                style: TextStyle(
                  color: _confidenceColor(confidence),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: confidence / 100,
              minHeight: 5,
              backgroundColor: context.colors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(_confidenceColor(confidence)),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Expanded(
                child: _statChip(
                  context,
                  Icons.speed_rounded,
                  'Signal',
                  signal.label,
                  signal.color,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _statChip(
                  context,
                  Icons.warning_amber_rounded,
                  'Risk',
                  risk.label,
                  risk.color,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _statChip(
                  context,
                  Icons.timer_outlined,
                  'Horizon',
                  '${coin.suggestedHoldingDays}d',
                  AppColors.info,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _statChip(
                  context,
                  distanceToTargetPercent >= 0
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  'To Target',
                  '${distanceToTargetPercent >= 0 ? '+' : ''}${distanceToTargetPercent.toStringAsFixed(1)}%',
                  trendColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.7),
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  Color _confidenceColor(int c) => c >= 70
      ? AppColors.bullish
      : c >= 45
      ? AppColors.warning
      : AppColors.bearish;

  _Tier _tier(int confidence, String strong, String mid, String weak) {
    if (confidence >= 70) return _Tier(strong, AppColors.bullish);
    if (confidence >= 45) return _Tier(mid, AppColors.warning);
    return _Tier(weak, AppColors.bearish);
  }
}

class _Tier {
  final String label;
  final Color color;
  const _Tier(this.label, this.color);
}

// ============== Trade plan panel ==============

class _TradePlanPanel extends StatelessWidget {
  final Coin coin;
  const _TradePlanPanel({required this.coin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TRADE PLAN',
            style: TextStyle(
              color: context.colors.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Row(
            children: [
              Expanded(
                child: _tile(
                  context,
                  'Entry zone',
                  '\$${coin.entryZoneLow.toStringAsFixed(2)}–\$${coin.entryZoneHigh.toStringAsFixed(2)}',
                  context.colors.onSurface,
                ),
              ),
              const SizedBox(width: AppSizes.xs),
              Expanded(
                child: _tile(
                  context,
                  'Exit target',
                  '\$${coin.exitTarget.toStringAsFixed(2)}',
                  AppColors.bullish,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.xs),
          Row(
            children: [
              Expanded(
                child: _tile(
                  context,
                  'Invalidation',
                  '\$${coin.invalidationLevel.toStringAsFixed(2)}',
                  AppColors.bearish,
                ),
              ),
              const SizedBox(width: AppSizes.xs),
              Expanded(
                child: _tile(
                  context,
                  'Allocation',
                  '${coin.suggestedInvestmentPercent.toStringAsFixed(0)}% of portfolio',
                  context.colors.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: context.colors.onSurfaceVariant,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ============== Buy/Sell action bar (dummy) ==============

class _TradeActionBar extends StatelessWidget {
  final Coin coin;
  final double livePrice;
  final TradeSide side;
  final TextEditingController amountController;
  final ValueChanged<TradeSide> onSideChanged;
  final VoidCallback onSubmit;

  const _TradeActionBar({
    required this.coin,
    required this.livePrice,
    required this.side,
    required this.amountController,
    required this.onSideChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final isBuy = side == TradeSide.buy;
    final actionColor = isBuy ? AppColors.bullish : AppColors.bearish;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.xs,
        AppSizes.md,
        AppSizes.xs + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Buy / Sell toggle ──────────────────────────
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _sideTab(
                    context,
                    'Buy',
                    TradeSide.buy,
                    AppColors.bullish,
                  ),
                ),
                Expanded(
                  child: _sideTab(
                    context,
                    'Sell',
                    TradeSide.sell,
                    AppColors.bearish,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // ── Amount input + qty preview ────────────────
          Row(
            children: [
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 38,
                  child: TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: TextStyle(
                      fontSize: 13,
                      color: context.colors.onSurface,
                    ),
                    decoration: InputDecoration(
                      prefixText: '\$ ',
                      prefixStyle: TextStyle(
                        fontSize: 13,
                        color: context.colors.onSurfaceVariant,
                      ),
                      isDense: true,
                      filled: true,
                      fillColor: context.colors.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    onPressed: onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: actionColor,
                      // actionColor is bullish (primary) or bearish (error);
                      // onPrimary/onError are both white in this theme.
                      foregroundColor: context.colors.onPrimary,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    child: Text(
                      isBuy ? 'Buy ${coin.symbol}' : 'Sell ${coin.symbol}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sideTab(
    BuildContext context,
    String label,
    TradeSide value,
    Color color,
  ) {
    final active = side == value;
    return GestureDetector(
      onTap: () => onSideChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: active ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            // color is bullish (primary) or bearish (error) — onPrimary and
            // onError are both white in this theme.
            color: active
                ? context.colors.onPrimary
                : context.colors.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
