import 'package:flutter/widgets.dart';
import '../core/ad_callbacks.dart';
import '../core/ad_network_adapter.dart';
import '../core/ad_network_type.dart';
import '../core/universal_ad_config.dart';

/// Pluggable adapter for ironSource mediation platform.
///
/// Ready to link with `ironsource_mediation` when ironSource is introduced in future releases.
class IronSourceAdapter implements AdNetworkAdapter {
  UniversalAdConfig? _config;
  bool _isInitialized = false;

  @override
  AdNetworkType get networkType => AdNetworkType.ironSource;

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize(UniversalAdConfig config) async {
    _config = config;
    final ironSourceConfig = config.ironSourceConfig;
    if (ironSourceConfig == null) return;

    // Pluggable hook: IronSource.validateIntegration(), IronSource.init(...)
    _isInitialized = true;
    _log("ironSource adapter registered and ready for integration.");
  }

  @override
  Widget buildBannerAd({
    required BuildContext context,
    OnAdFailedToLoad? onFailed,
    OnAdClicked? onClicked,
  }) {
    // Pluggable hook: IronSource.loadBanner(...)
    return const SizedBox.shrink();
  }

  @override
  Future<void> loadInterstitial({OnAdFailedToLoad? onFailed}) async {
    // Pluggable hook: IronSource.loadInterstitial(...)
  }

  @override
  bool isInterstitialReady() => false;

  @override
  Future<bool> showInterstitial({
    OnAdDismissed? onDismissed,
    OnAdFailedToLoad? onFailed,
    OnAdClicked? onClicked,
  }) async {
    // Pluggable hook: IronSource.showInterstitial(...)
    onDismissed?.call();
    return false;
  }

  @override
  Future<void> loadRewarded({OnAdFailedToLoad? onFailed}) async {
    // Pluggable hook: IronSource.loadRewardedVideo(...)
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
    // Pluggable hook: IronSource.showRewardedVideo(...)
    return false;
  }

  @override
  void dispose() {}

  void _log(String message) {
    if (_config?.verboseLogging ?? true) {
      debugPrint("[UniversalAds/IronSource] $message");
    }
  }
}
