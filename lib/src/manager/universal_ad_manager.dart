import 'package:flutter/widgets.dart';

import '../core/ad_callbacks.dart';
import '../core/ad_network_adapter.dart';
import '../core/ad_network_type.dart';
import '../core/universal_ad_config.dart';
import '../networks/admob_adapter.dart';
import '../networks/ironsource_adapter.dart';
import '../networks/unity_adapter.dart';
import 'ad_pacing_controller.dart';

/// Central facade managing ad networks, pacing, waterfalls, and displays.
class UniversalMobileAds {
  static final UniversalMobileAds _instance = UniversalMobileAds._internal();
  static UniversalMobileAds get instance => _instance;

  UniversalMobileAds._internal();

  UniversalAdConfig _config = const UniversalAdConfig();
  final Map<AdNetworkType, AdNetworkAdapter> _adapters = {};
  late AdPacingController _pacingController;
  bool _isInitialized = false;

  /// Global access to the active configuration.
  UniversalAdConfig get config => _config;

  /// Global access to the pacing controller.
  AdPacingController get pacing => _pacingController;

  /// Initializes the Universal Mobile Ads subsystem.
  static Future<void> initialize({
    required UniversalAdConfig config,
    int initialActionCount = 0,
    void Function(int actionsCount)? onCounterChanged,
  }) async {
    await _instance._init(
      config: config,
      initialActionCount: initialActionCount,
      onCounterChanged: onCounterChanged,
    );
  }

  Future<void> _init({
    required UniversalAdConfig config,
    required int initialActionCount,
    void Function(int actionsCount)? onCounterChanged,
  }) async {
    _config = config;
    _pacingController = AdPacingController(
      cooldown: config.interstitialCooldown,
      minActions: config.interstitialMinActions,
      initialActionCount: initialActionCount,
      onCounterChanged: onCounterChanged,
    );

    // Register built-in adapters
    registerAdapter(AdMobAdapter());
    registerAdapter(UnityAdsAdapter());
    registerAdapter(IronSourceAdapter());

    // Initialize primary network
    final primaryAdapter = _adapters[config.defaultNetwork];
    if (primaryAdapter != null) {
      await primaryAdapter.initialize(config);
    }

    _isInitialized = true;
    _log("Universal Mobile Ads initialized. Default network: ${config.defaultNetwork.name}");
  }

  /// Registers a custom or 3rd-party ad network adapter.
  void registerAdapter(AdNetworkAdapter adapter) {
    _adapters[adapter.networkType] = adapter;
  }

  /// Retrieves an adapter for the specified network type.
  AdNetworkAdapter? getAdapter(AdNetworkType type) => _adapters[type];

  /// Records a user action towards interstitial ad pacing.
  static void recordAction() {
    _instance._pacingController.recordAction();
  }

  /// Checks if an interstitial ad can be displayed based on pacing rules.
  static bool canShowInterstitial({bool isProUser = false}) {
    if (!_instance._isInitialized) return false;
    final canShowPaced = _instance._pacingController.canShowInterstitial(isProUser: isProUser);
    if (!canShowPaced) return false;

    // Verify at least one adapter has an ad ready
    final primary = _instance._adapters[_instance._config.defaultNetwork];
    return primary?.isInterstitialReady() ?? false;
  }

  /// Displays an interstitial ad respecting pacing, frequency capping, and Pro status.
  static Future<bool> showPacedInterstitial({
    bool isProUser = false,
    OnAdDismissed? onAdDismissed,
    OnAdFailedToLoad? onFailed,
    OnAdClicked? onClicked,
  }) async {
    if (!_instance._isInitialized) {
      onAdDismissed?.call();
      return false;
    }

    if (!_instance._pacingController.canShowInterstitial(isProUser: isProUser)) {
      onAdDismissed?.call();
      return false;
    }

    final primaryAdapter = _instance._adapters[_instance._config.defaultNetwork];
    if (primaryAdapter != null && primaryAdapter.isInterstitialReady()) {
      _instance._pacingController.recordAdShown();
      return primaryAdapter.showInterstitial(
        onDismissed: onAdDismissed,
        onFailed: onFailed,
        onClicked: onClicked,
      );
    }

    // Attempt waterfall fallback networks
    for (final fallback in _instance._config.fallbackNetworks) {
      final fallbackAdapter = _instance._adapters[fallback];
      if (fallbackAdapter != null && fallbackAdapter.isInterstitialReady()) {
        _instance._pacingController.recordAdShown();
        return fallbackAdapter.showInterstitial(
          onDismissed: onAdDismissed,
          onFailed: onFailed,
          onClicked: onClicked,
        );
      }
    }

    onAdDismissed?.call();
    return false;
  }

  /// Displays a rewarded video ad with fallback support across configured networks.
  static Future<bool> showRewardedAd({
    required OnUserEarnedReward onUserEarnedReward,
    OnAdDismissed? onAdDismissed,
    OnAdFailedToLoad? onFailed,
    OnAdClicked? onClicked,
  }) async {
    if (!_instance._isInitialized) {
      onFailed?.call(-1, "Universal Mobile Ads not initialized.");
      return false;
    }

    final primaryAdapter = _instance._adapters[_instance._config.defaultNetwork];
    if (primaryAdapter != null && primaryAdapter.isRewardedReady()) {
      return primaryAdapter.showRewarded(
        onUserEarnedReward: onUserEarnedReward,
        onDismissed: onAdDismissed,
        onFailed: onFailed,
        onClicked: onClicked,
      );
    }

    // Waterfall fallback
    for (final fallback in _instance._config.fallbackNetworks) {
      final fallbackAdapter = _instance._adapters[fallback];
      if (fallbackAdapter != null && fallbackAdapter.isRewardedReady()) {
        return fallbackAdapter.showRewarded(
          onUserEarnedReward: onUserEarnedReward,
          onDismissed: onAdDismissed,
          onFailed: onFailed,
          onClicked: onClicked,
        );
      }
    }

    onFailed?.call(-2, "No rewarded video ad is currently available.");
    return false;
  }

  /// Builds a Banner Ad widget for the primary or specified ad network.
  Widget buildBanner({
    required BuildContext context,
    AdNetworkType? networkType,
    OnAdFailedToLoad? onFailed,
    OnAdClicked? onClicked,
  }) {
    final type = networkType ?? _config.defaultNetwork;
    final adapter = _adapters[type];
    if (adapter == null) return const SizedBox.shrink();

    return adapter.buildBannerAd(
      context: context,
      onFailed: onFailed,
      onClicked: onClicked,
    );
  }

  void _log(String message) {
    if (_config.verboseLogging) {
      debugPrint("[UniversalAds] $message");
    }
  }
}
