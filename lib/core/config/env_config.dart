// lib/core/config/env_config.dart

class EnvConfig {
  EnvConfig._();

  /// CoinGecko Demo API key. Pass at build/run time with
  /// `--dart-define=COINGECKO_API_KEY=your_key_here` — the public API works
  /// without one, just at a much lower rate limit.
  static const String coinGeckoApiKey = String.fromEnvironment(
    'COINGECKO_API_KEY',
  );
}
