import 'package:flutter/widgets.dart';
import '../core/ad_callbacks.dart';
import '../core/ad_network_adapter.dart';
import '../core/ad_network_type.dart';
import '../core/universal_ad_config.dart';

/// Pluggable adapter for Unity Ads.
///
/// Ready to link with `unity_ads_plugin` when Unity Ads is introduced in future releases.
class UnityAdsAdapter implements AdNetworkAdapter {
  UniversalAdConfig? _config;
  bool _isInitialized = false;

  @override
  AdNetworkType get networkType => AdNetworkType.unity;

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize(UniversalAdConfig config) async {
    _config = config;
    final unityConfig = config.unityConfig;
    if (unityConfig == null) return;

    // Pluggable hook: UnityAds.init(...)
    _isInitialized = true;
    _log("Unity Ads adapter registered and ready for integration.");
  }

  @override
  Widget buildBannerAd({
    required BuildContext context,
    OnAdFailedToLoad? onFailed,
    OnAdClicked? onClicked,
  }) {
    // Pluggable hook: UnityBannerAd(...)
    return const SizedBox.shrink();
  }

  @override
  Future<void> loadInterstitial({OnAdFailedToLoad? onFailed}) async {
    // Pluggable hook: UnityAds.load(...)
  }

  @override
  bool isInterstitialReady() => false;

  @override
  Future<bool> showInterstitial({
    OnAdDismissed? onDismissed,
    OnAdFailedToLoad? onFailed,
    OnAdClicked? onClicked,
  }) async {
    // Pluggable hook: UnityAds.showVideoAd(...)
    onDismissed?.call();
    return false;
  }

  @override
  Future<void> loadRewarded({OnAdFailedToLoad? onFailed}) async {
    // Pluggable hook: UnityAds.load(...)
  }

  @override
  bool isRewardedReady() => false;

  @override
  Future<bool> showRewarded({
    required OnUserEarnedReward onUserEarnedReward,
    OnAdDismissed? onDismissed,
    OnAdFailedToLoad? onFailed,
    OnAdClicked? onClicked,
  }) async {
    // Pluggable hook: UnityAds.showVideoAd(...)
    return false;
  }

  @override
  void dispose() {}

  void _log(String message) {
    if (_config?.verboseLogging ?? true) {
      debugPrint("[UniversalAds/Unity] $message");
    }
  }
}
