import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trading_advisor/core/models/coin_model.dart';
import 'package:trading_advisor/core/theme/app_colors/app_colors.dart';
import 'package:trading_advisor/core/constants/sizes/sizes.dart';
import 'package:trading_advisor/ui/coin_chart_page.dart';
import 'package:trading_advisor/ui/homepage_view_model.dart';
import 'package:trading_advisor/ui/searchbar.dart';
import 'package:trading_advisor/widgets/price_change_card.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final isFirstLoad = vm.isLoading && vm.marketCoins.isEmpty;
    final loadFailed = vm.error != null && vm.marketCoins.isEmpty;

    return Scaffold(
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
                  SizedBox(height: AppSizes.sm),
                  CoinSearchBar(),
                  SizedBox(height: AppSizes.xs),
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
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        itemCount: coins.length,
        separatorBuilder: (_, _) => SizedBox(width: AppSizes.xs),
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
    final confidence = coin.confidenceScore; // 0-100

    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(18)),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 176,
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Trend accent strip ──────────────────────────
              Container(
                height: 3,
                decoration: BoxDecoration(color: trendColor),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header: avatar + symbol + trend chip ──
                    Row(
                      children: [
                        CoinAvatar(coin: coin, radius: 15),
                        const SizedBox(width: AppSizes.xs),
                        Expanded(
                          child: Text(
                            coin.symbol,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.priceChangeSurface(gain),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isUp
                                    ? Icons.arrow_upward_rounded
                                    : Icons.arrow_downward_rounded,
                                size: 11,
                                color: trendColor,
                              ),
                              Text(
                                '${gain.abs().toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: trendColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.sm),

                    // ── Current price ──────────────────────────
                    Text(
                      '\$${coin.currentPrice.toStringAsFixed(coin.currentPrice < 1 ? 4 : 2)}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // ── Target price, framed as the AI's claim ──
                    Row(
                      children: [
                        Icon(
                          Icons.trending_up_rounded,
                          size: 12,
                          color: trendColor,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Target \$${coin.predictedPrice.toStringAsFixed(coin.predictedPrice < 1 ? 4 : 2)}',
                          style: TextStyle(
                            color: trendColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.sm),

                    // ── AI confidence bar ───────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'AI CONFIDENCE',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                        Text(
                          '$confidence%',
                          style: TextStyle(
                            color: _confidenceColor(confidence),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: confidence / 100,
                        minHeight: 5,
                        backgroundColor: AppColors.softGrey,
                        valueColor: AlwaysStoppedAnimation(
                          _confidenceColor(confidence),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),

                    // ── Timeframe ────────────────────────────────
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'by ${_formatDate(coin.targetDate)}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Confidence tiers, so a 40% "confident" claim doesn't read as visually
  /// reassuring as a 90% one — the color itself communicates reliability.
  Color _confidenceColor(int confidence) {
    if (confidence >= 70) return AppColors.bullish;
    if (confidence >= 45) return AppColors.warning;
    return AppColors.bearish;
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
    final isUp = gain >= 0;
    final confidence = coin.confidenceScore;

    // Derived AI stats for display — these should come straight off the
    // model/agent response once it's real; computed here only because the
    // Coin model doesn't carry them yet.
    final riskLevel = _riskLevel(coin);
    final signalStrength = _signalStrength(confidence);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(
              AppSizes.lg,
              AppSizes.sm,
              AppSizes.lg,
              AppSizes.lg,
            ),
            children: [
              // ── Drag handle ──────────────────────────────────
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSizes.md),
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              // ── Header ───────────────────────────────────────
              Row(
                children: [
                  CoinAvatar(coin: coin, radius: 22),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coin.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 17,
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
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: trendColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isUp ? 'BULLISH' : 'BEARISH',
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.lg),

              // ── Price comparison ─────────────────────────────
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _priceBlock(
                        'Current',
                        coin.currentPrice,
                        AppColors.textPrimary,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.textMuted,
                      size: 18,
                    ),
                    Expanded(
                      child: _priceBlock(
                        'AI Target',
                        coin.predictedPrice,
                        trendColor,
                        alignEnd: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.md),

              // ── AI Analysis ───────────────────────────────────
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.psychology_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'AI ANALYSIS',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Confidence this target is reached',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$confidence%',
                          style: TextStyle(
                            color: _confidenceColor(confidence),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: confidence / 100,
                        minHeight: 6,
                        backgroundColor: AppColors.softGrey,
                        valueColor: AlwaysStoppedAnimation(
                          _confidenceColor(confidence),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                    Row(
                      children: [
                        Expanded(
                          child: _aiStatChip(
                            icon: Icons.speed_rounded,
                            label: 'Signal',
                            value: signalStrength.label,
                            color: signalStrength.color,
                          ),
                        ),
                        const SizedBox(width: AppSizes.xs),
                        Expanded(
                          child: _aiStatChip(
                            icon: Icons.warning_amber_rounded,
                            label: 'Risk',
                            value: riskLevel.label,
                            color: riskLevel.color,
                          ),
                        ),
                        const SizedBox(width: AppSizes.xs),
                        Expanded(
                          child: _aiStatChip(
                            icon: Icons.timer_outlined,
                            label: 'Horizon',
                            value: '${coin.suggestedHoldingDays}d',
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.md),

              // ── Trade plan grid ───────────────────────────────
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TRADE PLAN',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Row(
                      children: [
                        Expanded(
                          child: _tradeStat(
                            'Entry zone',
                            '\$${coin.entryZoneLow.toStringAsFixed(2)} – \$${coin.entryZoneHigh.toStringAsFixed(2)}',
                            AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: _tradeStat(
                            'Exit target',
                            '\$${coin.exitTarget.toStringAsFixed(2)}',
                            AppColors.bullish,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Row(
                      children: [
                        Expanded(
                          child: _tradeStat(
                            'Invalidation',
                            '\$${coin.invalidationLevel.toStringAsFixed(2)}',
                            AppColors.bearish,
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: _tradeStat(
                            'Allocation',
                            '${coin.suggestedInvestmentPercent.toStringAsFixed(0)}% of portfolio',
                            AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              // ── CTA ────────────────────────────────────────────
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
                'AI-generated signal, not financial advice. Not auto-executed.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _priceBlock(
    String label,
    double price,
    Color valueColor, {
    bool alignEnd = false,
  }) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          '\$${price.toStringAsFixed(price < 1 ? 4 : 2)}',
          style: TextStyle(
            color: valueColor,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _aiStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _tradeStat(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Color _confidenceColor(int confidence) {
    if (confidence >= 70) return AppColors.bullish;
    if (confidence >= 45) return AppColors.warning;
    return AppColors.bearish;
  }

  _Tier _riskLevel(Coin coin) {
    final spreadPercent =
        ((coin.entryZoneHigh - coin.invalidationLevel).abs() /
            coin.currentPrice) *
        100;
    if (spreadPercent >= 12) return _Tier('High', AppColors.bearish);
    if (spreadPercent >= 6) return _Tier('Medium', AppColors.warning);
    return _Tier('Low', AppColors.bullish);
  }

  _Tier _signalStrength(int confidence) {
    if (confidence >= 70) return _Tier('Strong', AppColors.bullish);
    if (confidence >= 45) return _Tier('Moderate', AppColors.warning);
    return _Tier('Weak', AppColors.bearish);
  }
}

class _Tier {
  final String label;
  final Color color;
  const _Tier(this.label, this.color);
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
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
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
