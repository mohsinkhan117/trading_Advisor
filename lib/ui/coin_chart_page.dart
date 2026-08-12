import 'package:flutter/material.dart';
import 'package:trading_advisor/core/models/coin_model.dart';
import 'package:trading_advisor/core/theme/app_colors/app_colors.dart';
import 'package:trading_advisor/core/constants/sizes/sizes.dart';
import 'package:trading_advisor/services/coin_api_service.dart';
import 'package:trading_chart_flutter/trading_chart_flutter.dart';

class CoinChartPage extends StatefulWidget {
  final Coin coin;
  const CoinChartPage({super.key, required this.coin});

  @override
  State<CoinChartPage> createState() => _CoinChartPageState();
}

class _CoinChartPageState extends State<CoinChartPage> {
  final CoinApiService _api = CoinApiService();

  List<Candle> _candles = [];
  bool _isLoading = true;
  bool _showVolume = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadChart();
  }

  Future<void> _loadChart() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final candles = await _api.fetchChartCandles(widget.coin.id);
      if (!mounted) return;
      setState(() {
        _candles = candles;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load chart data: $e';
        _isLoading = false;
      });
    }
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
        actions: [
          IconButton(
            icon: Icon(
              _showVolume
                  ? Icons.bar_chart_rounded
                  : Icons.bar_chart_outlined,
            ),
            onPressed: () => setState(() => _showVolume = !_showVolume),
            tooltip: _showVolume ? 'Hide volume' : 'Show volume',
          ),
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
            onPressed: _isLoading ? null : _loadChart,
            tooltip: 'Refresh chart',
          ),
        ],
      ),
      body: _buildBody(coin, gain, trendColor),
    );
  }

  Widget _buildBody(Coin coin, double gain, Color trendColor) {
    if (_isLoading && _candles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _candles.isEmpty) {
      return _ChartErrorState(message: _error!, onRetry: _loadChart);
    }

    return Column(
      children: [
        _PriceHeader(coin: coin, gain: gain, trendColor: trendColor),
        const SizedBox(height: AppSizes.sm),
        Expanded(
          child: InteractiveTradingChart(
            candles: _candles,
            theme: ChartTheme.dark,
            showVolume: _showVolume,
          ),
        ),
        _RecommendationFooter(coin: coin, trendColor: trendColor),
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
            const Icon(
              Icons.cloud_off_rounded,
              size: 40,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
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
  final Coin coin;
  final double gain;
  final Color trendColor;

  const _PriceHeader({
    required this.coin,
    required this.gain,
    required this.trendColor,
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
