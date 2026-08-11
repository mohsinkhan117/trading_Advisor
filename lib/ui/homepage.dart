import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trading_advisor/core/models/coin_model.dart';
import 'package:trading_advisor/core/theme/app_colors/app_colors.dart';
import 'package:trading_advisor/core/constants/sizes/sizes.dart';
import 'package:trading_advisor/ui/coin_chart_page.dart';
import 'package:trading_advisor/ui/homepage_view_model.dart';
import 'package:trading_advisor/widgets/price_change_card.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final isFirstLoad = vm.isLoading && vm.marketCoins.isEmpty;
    final loadFailed = vm.error != null && vm.marketCoins.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: const Text('Market Overview'),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => context.read<HomeViewModel>().refresh(),
        child: isFirstLoad
            ? const Center(child: CircularProgressIndicator())
            : loadFailed
                ? _ErrorState(
                    message: vm.error!,
                    onRetry: () => context.read<HomeViewModel>().refresh(),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                    children: const [
                      _SectionHeader(title: 'Recommended Coins'),
                      SizedBox(height: AppSizes.sm),
                      RecommendedCoins(),
                      SizedBox(height: AppSizes.lg),
                      _SectionHeader(title: 'Market'),
                      SizedBox(height: AppSizes.sm),
                      MarketOverview(),
                    ],
                  ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSizes.lg),
      children: [
        const SizedBox(height: 80),
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
        Center(
          child: ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ============== Recommendation ==============

class RecommendedCoins extends StatelessWidget {
  const RecommendedCoins({super.key});

  @override
  Widget build(BuildContext context) {
    final coins = context.watch<HomeViewModel>().recommendedCoins;

    return SizedBox(
      height: 168,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        itemCount: coins.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSizes.sm),
        itemBuilder: (context, index) {
          final coin = coins[index];
          return RecommendedCoin(
            coin: coin,
            onTap: () {
              context.read<HomeViewModel>().selectCoin(coin);
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (_) => CoinDetails(coin: coin),
              );
            },
          );
        },
      ),
    );
  }
}

class RecommendedCoin extends StatelessWidget {
  final Coin coin;
  final VoidCallback onTap;

  const RecommendedCoin({super.key, required this.coin, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final gain = coin.expectedGainPercent;
    final trendColor = AppColors.priceChangeColor(gain);
    final isUp = gain >= 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CoinAvatar(coin: coin, radius: 14),
                const SizedBox(width: AppSizes.xs),
                Text(
                  coin.symbol,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              '\$${coin.currentPrice.toStringAsFixed(coin.currentPrice < 1 ? 4 : 2)}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isUp ? Icons.trending_up : Icons.trending_down,
                  size: 14,
                  color: trendColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${gain.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: trendColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              'by ${_formatDate(coin.targetDate)}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.month}/${d.day}';
}

// this card will open for every coin when user clicks on it
class CoinDetails extends StatelessWidget {
  final Coin coin;
  const CoinDetails({super.key, required this.coin});

  @override
  Widget build(BuildContext context) {
    final gain = coin.expectedGainPercent;
    final trendColor = AppColors.priceChangeColor(gain);
    final trendSurface = AppColors.priceChangeSurface(gain);
    final isUp = gain >= 0;

    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CoinAvatar(coin: coin, radius: 20),
              const SizedBox(width: AppSizes.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coin.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    coin.symbol,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: trendSurface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isUp ? 'BULLISH' : 'BEARISH',
                  style: TextStyle(
                    color: trendColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          Row(
            children: [
              Expanded(
                child: _statBlock(
                  'Current Price',
                  '\$${coin.currentPrice.toStringAsFixed(2)}',
                ),
              ),
              Expanded(
                child: _statBlock(
                  'Target Price',
                  '\$${coin.predictedPrice.toStringAsFixed(2)}',
                  valueColor: trendColor,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Confidence',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.confidenceBadgeBackground,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${coin.confidenceScore}%',
                        style: const TextStyle(
                          color: AppColors.confidenceBadgeText,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          const Divider(color: AppColors.cardBorder),
          const SizedBox(height: AppSizes.md),
          _detailRow(
            'Suggested holding window',
            '${coin.suggestedHoldingDays} days',
          ),
          _detailRow(
            'Suggested allocation',
            '${coin.suggestedInvestmentPercent.toStringAsFixed(0)}% of portfolio',
          ),
          _detailRow(
            'Entry zone',
            '\$${coin.entryZoneLow.toStringAsFixed(2)} – \$${coin.entryZoneHigh.toStringAsFixed(2)}',
          ),
          _detailRow('Exit target', '\$${coin.exitTarget.toStringAsFixed(2)}'),
          _detailRow(
            'Invalidation level',
            '\$${coin.invalidationLevel.toStringAsFixed(2)}',
          ),
          const SizedBox(height: AppSizes.lg),
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.buttonActiveLinearGradientColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CoinChartPage(coin: coin),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.show_chart,
                  size: 18,
                  color: AppColors.textWhite,
                ),
                label: const Text(
                  'View Chart',
                  style: TextStyle(color: AppColors.textWhite),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          const Text(
            'Educational signal, not financial advice. Not auto-executed.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _statBlock(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class CoinAvatar extends StatelessWidget {
  final Coin coin;
  final double radius;

  const CoinAvatar({super.key, required this.coin, this.radius = 14});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.iconAvatarBackground,
      child: ClipOval(
        child: Image.network(
          coin.iconUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return SizedBox(
              width: radius,
              height: radius,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: AppColors.primary,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            // CDN miss / offline — fall back to the emoji glyph
            return Text(coin.iconEmoji, style: TextStyle(fontSize: radius));
          },
        ),
      ),
    );
  }
}

//=============== market overview list ==============
class MarketOverview extends StatelessWidget {
  const MarketOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final coins = context.watch<HomeViewModel>().marketCoins;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSizes.md),
      itemCount: coins.length,
      itemBuilder: (context, index) {
        final coin = coins[index];
        return PriceChangeCard(
          symbol: coin.symbol,
          name: coin.name,
          price: coin.currentPrice,
          change: coin.changeAmount24h,
          changePercent: coin.changePercent24h,
          onTap: () {
            context.read<HomeViewModel>().selectCoin(coin);
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (_) => CoinDetails(coin: coin),
            );
          },
        );
      },
    );
  }
}
