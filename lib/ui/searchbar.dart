// lib/ui/searchbar.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:trading_advisor/core/models/search_model.dart';
import 'package:trading_advisor/core/theme/app_colors/app_colors.dart';
import 'package:trading_advisor/core/theme/context_theme_ext.dart';
import 'package:trading_advisor/core/constants/sizes/sizes.dart';
import 'package:trading_advisor/services/coin_api_service.dart';
import 'package:trading_advisor/ui/coin_chart_page.dart';

class CoinSearchBar extends StatefulWidget {
  const CoinSearchBar({super.key});

  @override
  State<CoinSearchBar> createState() => _CoinSearchBarState();
}

class _CoinSearchBarState extends State<CoinSearchBar> {
  final CoinApiService _api = CoinApiService();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Timer? _debounce;
  List<CoinSearchResult> _results = [];
  bool _isLoading = false;
  bool _isResolving = false;
  String? _error;
  bool _panelOpen = false; // now driven explicitly, not by focus

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    _debounce?.cancel();
    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false;
        _error = null;
        _panelOpen = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _panelOpen = true; // open as soon as the user starts typing
    });
    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => _search(trimmed),
    );
  }

  Future<void> _search(String query) async {
    try {
      final results = await _api.searchCoins(query);
      if (!mounted || _controller.text.trim() != query) return;
      setState(() {
        _results = results;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Search failed';
      });
    }
  }

  Future<void> _selectCoin(CoinSearchResult result) async {
    // Close the panel immediately on selection — deliberate, not a
    // side-effect of losing focus, so there's no race with the tap.
    setState(() {
      _panelOpen = false;
      _isResolving = true;
    });
    _focusNode.unfocus();

    try {
      final coin = await _api.fetchCoinById(result.id);
      if (!mounted) return;
      setState(() {
        _controller.clear();
        _results = [];
        _isResolving = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CoinChartPage(coin: coin)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isResolving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load ${result.symbol}: $e')),
      );
    }
  }

  void _clear() {
    _controller.clear();
    setState(() {
      _results = [];
      _isLoading = false;
      _error = null;
      _panelOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      // Closes the panel only on a genuine outside tap — never mid-selection.
      onTapOutside: (_) {
        if (_panelOpen) setState(() => _panelOpen = false);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Search field ──────────────────────────────────
          Container(
            height: 44,
            decoration: BoxDecoration(
              // color: context.colors.surface,
              borderRadius: BorderRadius.circular(_panelOpen ? 14 : 22)
                  .copyWith(
                    bottomLeft: _panelOpen
                        ? const Radius.circular(4)
                        : const Radius.circular(22),
                    bottomRight: _panelOpen
                        ? const Radius.circular(4)
                        : const Radius.circular(22),
                  ),
            ),
            child: Row(
              children: [
                const SizedBox(width: AppSizes.sm),
                Icon(
                  Icons.search_rounded,
                  size: 19,
                  color: _focusNode.hasFocus
                      ? context.colors.primary
                      : AppColors.borderPrimary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onChanged: _onChanged,
                    onTap: () {
                      if (_results.isNotEmpty ||
                          _controller.text.trim().isNotEmpty) {
                        setState(() => _panelOpen = true);
                      }
                    },
                    style: context.textStyles.bodyMedium?.copyWith(
                      fontSize: 13,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search coins, e.g. Bitcoin or SOL',
                      hintStyle: context.textStyles.bodyMedium?.copyWith(
                        fontSize: 13,
                        color: AppColors
                            .textMuted, // hint color — separate from border color
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide(
                          color: AppColors.borderPrimary,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide(
                          color: context.colors.primary,
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_isLoading || _isResolving)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSizes.sm),
                    child: SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.colors.primary,
                      ),
                    ),
                  )
                else if (_controller.text.isNotEmpty)
                  InkWell(
                    onTap: _clear,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.xs),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        // color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: AppSizes.sm),
              ],
            ),
          ),

          // ── Results panel ─────────────────────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: _panelOpen
                ? _buildResultsPanel()
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsPanel() {
    return Container(
      margin: const EdgeInsets.only(top: 2),
      constraints: const BoxConstraints(maxHeight: 320),
      decoration: BoxDecoration(
        // color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
      ),
      child: _buildResultsContent(),
    );
  }

  Widget _buildResultsContent() {
    if (_error != null) {
      return _panelMessage(
        Icons.error_outline_rounded,
        _error!,
        AppColors.bearish,
      );
    }
    if (_isLoading && _results.isEmpty) {
      return SizedBox(
        height: 64,
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: context.colors.primary,
            ),
          ),
        ),
      );
    }
    if (_results.isEmpty) {
      return _panelMessage(
        Icons.search_off_rounded,
        'No coins found',
        context.colors.onSurfaceVariant,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 4),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _results.length,
      separatorBuilder: (_, _) => Divider(
        height: 1,
        thickness: 0.6,
        indent: 56,
        color: context.colors.outlineVariant,
      ),
      itemBuilder: (context, index) => _ResultTile(
        result: _results[index],
        onTap: () => _selectCoin(_results[index]),
      ),
    );
  }

  Widget _panelMessage(IconData icon, String text, Color color) {
    return SizedBox(
      height: 64,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(text, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// ============== Result tile ==============

class _ResultTile extends StatelessWidget {
  final CoinSearchResult result;
  final VoidCallback onTap;

  const _ResultTile({required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sm,
          vertical: 8,
        ),
        child: Row(
          children: [
            ClipOval(
              child: Image.network(
                result.thumbUrl,
                width: 28,
                height: 28,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: context.colors.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      result.symbol.isNotEmpty ? result.symbol[0] : '?',
                      style: context.textStyles.bodySmall?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodyMedium?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    result.symbol.toUpperCase(),
                    style: context.textStyles.bodySmall?.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            if (result.marketCapRank != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '#${result.marketCapRank}',
                  style: context.textStyles.bodySmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
