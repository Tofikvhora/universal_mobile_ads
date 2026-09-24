import 'package:flutter/widgets.dart';
import 'ad_callbacks.dart';
import 'ad_network_type.dart';
import 'universal_ad_config.dart';

/// Contract that every integrated ad network provider must implement.
abstract class AdNetworkAdapter {
  /// Identifies the ad network platform.
  AdNetworkType get networkType;

  /// Returns true if the network SDK has completed initialization.
  bool get isInitialized;

  /// Initializes the ad network SDK with the global config.
  Future<void> initialize(UniversalAdConfig config);

  /// Renders a banner ad widget.
  Widget buildBannerAd({
    required BuildContext context,
    OnAdFailedToLoad? onFailed,
    OnAdClicked? onClicked,
  });

  /// Preloads an interstitial ad into memory.
  Future<void> loadInterstitial({
    OnAdFailedToLoad? onFailed,
  });

  /// Checks if an interstitial ad is loaded and ready for display.
  bool isInterstitialReady();

  /// Displays the loaded interstitial ad.
  Future<bool> showInterstitial({
    OnAdDismissed? onDismissed,
    OnAdFailedToLoad? onFailed,
    OnAdClicked? onClicked,
  });

  /// Preloads a rewarded video ad into memory.
  Future<void> loadRewarded({
    OnAdFailedToLoad? onFailed,
  });

  /// Checks if a rewarded video ad is loaded and ready for display.
  bool isRewardedReady();

  /// Displays the loaded rewarded video ad.
  Future<bool> showRewarded({
    required OnUserEarnedReward onUserEarnedReward,
    OnAdDismissed? onDismissed,
    OnAdFailedToLoad? onFailed,
    OnAdClicked? onClicked,
  });

  /// Releases resources held by this adapter.
  void dispose();
}
