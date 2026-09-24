import 'ad_network_type.dart';
import 'ad_unit_id_config.dart';

/// Central configuration for Universal Mobile Ads.
class UniversalAdConfig {
  /// Primary ad network to attempt loading ads from (defaults to `AdNetworkType.admob`).
  final AdNetworkType defaultNetwork;

  /// Ordered list of fallback networks to attempt if the primary network has no fill or errors.
  final List<AdNetworkType> fallbackNetworks;

  /// When true, official test ad units are served to prevent invalid traffic policy flags.
  final bool isTestMode;

  /// Configuration for Google AdMob.
  final AdNetworkConfig? adMobConfig;

  /// Configuration for Unity Ads.
  final AdNetworkConfig? unityConfig;

  /// Configuration for ironSource.
  final AdNetworkConfig? ironSourceConfig;

  /// Configuration for AppLovin.
  final AdNetworkConfig? appLovinConfig;

  /// Minimum cooldown duration between two interstitial ad impressions.
  final Duration interstitialCooldown;

  /// Minimum number of user actions / events required before an interstitial is eligible to display.
  final int interstitialMinActions;

  /// Enable detailed logging in debug console.
  final bool verboseLogging;

  const UniversalAdConfig({
    this.defaultNetwork = AdNetworkType.admob,
    this.fallbackNetworks = const [
      AdNetworkType.unity,
      AdNetworkType.ironSource,
    ],
    this.isTestMode = false,
    this.adMobConfig,
    this.unityConfig,
    this.ironSourceConfig,
    this.appLovinConfig,
    this.interstitialCooldown = const Duration(seconds: 15),
    this.interstitialMinActions = 3,
    this.verboseLogging = true,
  });

  /// Retrieves network configuration for the specified ad network.
  AdNetworkConfig? getConfigFor(AdNetworkType type) {
    switch (type) {
      case AdNetworkType.admob:
        return adMobConfig;
      case AdNetworkType.unity:
        return unityConfig;
      case AdNetworkType.ironSource:
        return ironSourceConfig;
      case AdNetworkType.applovin:
        return appLovinConfig;
      case AdNetworkType.custom:
        return null;
    }
  }
}
