import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

import '../core/ad_callbacks.dart';
import '../core/ad_network_adapter.dart';
import '../core/ad_network_type.dart';
import '../core/universal_ad_config.dart';

/// Production-ready adapter for Unity Ads with full fallback capabilities.
class UnityAdsAdapter implements AdNetworkAdapter {
  UniversalAdConfig? _config;
  bool _isInitialized = false;
  bool _isInterstitialLoaded = false;
  bool _isRewardedLoaded = false;

  @override
  AdNetworkType get networkType => AdNetworkType.unity;

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize(UniversalAdConfig config) async {
    _config = config;
    final unityConfig = config.unityConfig;
    if (unityConfig == null) return;

    final gameId = (Platform.isIOS ? unityConfig.appIdIOS : unityConfig.appIdAndroid) ?? '';
    if (gameId.isEmpty) return;

    try {
      await UnityAds.init(
        gameId: gameId,
        testMode: config.isTestMode,
        onComplete: () {
          _isInitialized = true;
          _log("Unity Ads initialized successfully for gameId: $gameId");
          // Pre-load interstitial and rewarded placements
          loadInterstitial();
          loadRewarded();
        },
        onFailed: (error, message) {
          _isInitialized = false;
          _log("Unity Ads initialization failed: $error - $message");
        },
      );
      _isInitialized = true;
    } catch (e) {
      _log("Error initializing Unity Ads: $e");
    }
  }

  @override
  Widget buildBannerAd({
    required BuildContext context,
    OnAdFailedToLoad? onFailed,
    OnAdClicked? onClicked,
  }) {
    final unityConfig = _config?.unityConfig;
    final placementId = (Platform.isIOS ? unityConfig?.bannerIdIOS : unityConfig?.bannerIdAndroid) ?? '';
    if (placementId.isEmpty || !_isInitialized) {
      return const SizedBox.shrink();
    }

    return UnityBannerAd(
      placementId: placementId,
      onClick: (placement) => onClicked?.call(),
      onFailed: (placement, error, message) => onFailed?.call(-1, message),
    );
  }

  @override
  Future<void> loadInterstitial({OnAdFailedToLoad? onFailed}) async {
    final unityConfig = _config?.unityConfig;
    final placementId = (Platform.isIOS ? unityConfig?.interstitialIdIOS : unityConfig?.interstitialIdAndroid) ?? '';
    if (placementId.isEmpty || !_isInitialized) return;

    try {
      await UnityAds.load(
        placementId: placementId,
        onComplete: (placement) {
          _isInterstitialLoaded = true;
          _log("Unity Interstitial loaded: $placement");
        },
        onFailed: (placement, error, message) {
          _isInterstitialLoaded = false;
          _log("Unity Interstitial load failed: $error - $message");
          onFailed?.call(-1, message);
        },
      );
    } catch (e) {
      _log("Error loading Unity Interstitial: $e");
    }
  }

  @override
  bool isInterstitialReady() => _isInterstitialLoaded;

  @override
  Future<bool> showInterstitial({
    OnAdDismissed? onDismissed,
    OnAdFailedToLoad? onFailed,
    OnAdClicked? onClicked,
  }) async {
    final unityConfig = _config?.unityConfig;
    final placementId = (Platform.isIOS ? unityConfig?.interstitialIdIOS : unityConfig?.interstitialIdAndroid) ?? '';
    if (placementId.isEmpty || !_isInitialized) {
      onFailed?.call(-1, "Unity Ads not initialized or missing placement.");
      return false;
    }

    _isInterstitialLoaded = false;
    var completed = false;

    try {
      await UnityAds.showVideoAd(
        placementId: placementId,
        onClick: (placement) => onClicked?.call(),
        onComplete: (placement) {
          completed = true;
          onDismissed?.call();
          loadInterstitial();
        },
        onSkipped: (placement) {
          completed = true;
          onDismissed?.call();
          loadInterstitial();
        },
        onFailed: (placement, error, message) {
          onFailed?.call(-1, message);
          loadInterstitial();
        },
      );
      return completed;
    } catch (e) {
      _log("Error showing Unity Interstitial: $e");
      onFailed?.call(-1, e.toString());
      return false;
    }
  }

  @override
  Future<void> loadRewarded({OnAdFailedToLoad? onFailed}) async {
    final unityConfig = _config?.unityConfig;
    final placementId = (Platform.isIOS ? unityConfig?.rewardedIdIOS : unityConfig?.rewardedIdAndroid) ?? '';
    if (placementId.isEmpty || !_isInitialized) return;

    try {
      await UnityAds.load(
        placementId: placementId,
        onComplete: (placement) {
          _isRewardedLoaded = true;
          _log("Unity Rewarded loaded: $placement");
        },
        onFailed: (placement, error, message) {
          _isRewardedLoaded = false;
          _log("Unity Rewarded load failed: $error - $message");
          onFailed?.call(-1, message);
        },
      );
    } catch (e) {
      _log("Error loading Unity Rewarded: $e");
    }
  }

  @override
  bool isRewardedReady() => _isRewardedLoaded;

  @override
  Future<bool> showRewarded({
    required OnUserEarnedReward onUserEarnedReward,
    OnAdDismissed? onDismissed,
    OnAdFailedToLoad? onFailed,
    OnAdClicked? onClicked,
  }) async {
    final unityConfig = _config?.unityConfig;
    final placementId = (Platform.isIOS ? unityConfig?.rewardedIdIOS : unityConfig?.rewardedIdAndroid) ?? '';
    if (placementId.isEmpty || !_isInitialized) {
      onFailed?.call(-1, "Unity Ads not initialized or missing placement.");
      return false;
    }

    _isRewardedLoaded = false;
    var rewarded = false;

    try {
      await UnityAds.showVideoAd(
        placementId: placementId,
        onClick: (placement) => onClicked?.call(),
        onComplete: (placement) {
          rewarded = true;
          onUserEarnedReward(1, 'unity_reward');
          onDismissed?.call();
          loadRewarded();
        },
        onSkipped: (placement) {
          onDismissed?.call();
          loadRewarded();
        },
        onFailed: (placement, error, message) {
          onFailed?.call(-1, message);
          loadRewarded();
        },
      );
      return rewarded;
    } catch (e) {
      _log("Error showing Unity Rewarded: $e");
      onFailed?.call(-1, e.toString());
      return false;
    }
  }

  @override
  void dispose() {
    _isInitialized = false;
    _isInterstitialLoaded = false;
    _isRewardedLoaded = false;
  }

  void _log(String message) {
    if (_config?.verboseLogging ?? true) {
      debugPrint("[UniversalAds/Unity] $message");
    }
  }
}
