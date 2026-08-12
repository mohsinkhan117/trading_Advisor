// lib/core/widgets/price_change_card.dart

import 'package:flutter/material.dart';
import 'package:trading_advisor/core/constants/sizes/sizes.dart';
import 'package:trading_advisor/core/theme/app_colors/app_colors.dart';
import 'package:trading_advisor/core/utils/formatting_utils/formatting_utils.dart';

/// A compact, borderless row for showing a symbol's price and its change.
///
/// Icon, change text derive from [AppColors.priceChangeColor] so gain/loss
/// coloring stays consistent with the app's candlestick palette everywhere
/// it's used (watchlists, portfolio, recommendations, etc.). No card border
/// or shadow — rows are separated by a single trailing divider, matching a
/// dense market-list layout instead of stacked cards.
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
    final icon = change > 0
        ? Icons.arrow_upward_rounded
        : change < 0
        ? Icons.arrow_downward_rounded
        : Icons.remove_rounded;
    final sign = change > 0 ? '+' : '';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: AppSizes.iconMd,
                  height: AppSizes.iconMd,
                  decoration: BoxDecoration(
                    color: changeColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.textWhite, size: 14),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        symbol,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (name != null)
                        Text(
                          name!,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
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
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '$sign${change.toStringAsFixed(2)} ($sign${changePercent.toStringAsFixed(2)}%)',
                      style: TextStyle(
                        color: changeColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            const Divider(
              height: 1,
              thickness: 0.6,
              color: AppColors.cardBorder,
            ),
          ],
        ),
      ),
    );
  }
}
