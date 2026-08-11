// lib/core/widgets/price_change_card.dart

import 'package:flutter/material.dart';
import 'package:trading_advisor/core/constants/sizes/sizes.dart';
import 'package:trading_advisor/core/theme/app_colors/app_colors.dart';
import 'package:trading_advisor/core/utils/formatting_utils/formatting_utils.dart';

/// A candle-colored card for showing a symbol's price and its change.
///
/// Card accent, icon, and change text all derive from [AppColors.priceChangeColor]
/// so gain/loss coloring stays consistent with the app's candlestick palette
/// everywhere it's used (watchlists, portfolio, recommendations, etc.).
class PriceChangeCard extends StatelessWidget {
  final String symbol;
  final String? name;
  final double price;
  final double change;
  final double changePercent;
  final VoidCallback? onTap;

  const PriceChangeCard({
    super.key,
    required this.symbol,
    required this.price,
    required this.change,
    required this.changePercent,
    this.name,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final changeColor = AppColors.priceChangeColor(change);
    final changeSurface = AppColors.priceChangeSurface(change);
    final changeBorder = AppColors.priceChangeBorder(change);
    final icon = change > 0
        ? Icons.arrow_upward_rounded
        : change < 0
            ? Icons.arrow_downward_rounded
            : Icons.remove_rounded;
    final sign = change > 0 ? '+' : '';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppSizes.xs),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Row(
            children: [
              Container(
                width: AppSizes.iconLg + AppSizes.sm,
                height: AppSizes.iconLg + AppSizes.sm,
                decoration: BoxDecoration(
                  color: changeSurface,
                  shape: BoxShape.circle,
                  border: Border.all(color: changeBorder),
                ),
                child: Icon(icon, color: changeColor, size: AppSizes.iconMd),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      symbol,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (name != null)
                      Text(
                        name!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppFormatUtils.formatCurrency(price),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: changeSurface,
                      borderRadius:
                          BorderRadius.circular(AppSizes.borderRadiusSm),
                    ),
                    child: Text(
                      '$sign${change.toStringAsFixed(2)} ($sign${changePercent.toStringAsFixed(2)}%)',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: changeColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
