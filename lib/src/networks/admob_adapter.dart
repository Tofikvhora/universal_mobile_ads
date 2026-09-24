import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' as gma;

import '../core/ad_callbacks.dart';
import '../core/ad_network_adapter.dart';
import '../core/ad_network_type.dart';
import '../core/universal_ad_config.dart';

/// Full Google AdMob network adapter implementation.
class AdMobAdapter implements AdNetworkAdapter {
  UniversalAdConfig? _config;
  bool _isInitialized = false;

  gma.InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;

  gma.RewardedAd? _rewardedAd;
  bool _isRewardedLoading = false;

  @override
  AdNetworkType get networkType => AdNetworkType.admob;

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize(UniversalAdConfig config) async {
    _config = config;
    if (kIsWeb) {
      _log("AdMob is not supported on Web platform.");
      return;
    }

    try {
      final status = await gma.MobileAds.instance.initialize();
      _isInitialized = true;
      _log("AdMob SDK initialized successfully: ${status.adapterStatuses}");

      // Preload initial full-screen ad inventory
      loadInterstitial();
      loadRewarded();
    } catch (e) {
      _log("AdMob initialization error: $e");
    }
  }

  @override
  Widget buildBannerAd({
    required BuildContext context,
    OnAdFailedToLoad? onFailed,
    OnAdClicked? onClicked,
  }) {
    if (kIsWeb || !_isInitialized || _config == null) {
      return const SizedBox.shrink();
    }

    return _AdMobBannerWidget(
      config: _config!,
      onFailed: onFailed,
      onClicked: onClicked,
    );
  }

  @override
  Future<void> loadInterstitial({OnAdFailedToLoad? onFailed}) async {
    if (kIsWeb || !_isInitialized || _config == null) return;
    if (_interstitialAd != null || _isInterstitialLoading) return;

    _isInterstitialLoading = true;
    final adUnitId = _config!.adMobConfig?.getInterstitialId(
          isTestMode: _config!.isTestMode,
        ) ??
        '';

    _log("Loading AdMob Interstitial ad: $adUnitId");

    await gma.InterstitialAd.load(
      adUnitId: adUnitId,
      request: const gma.AdRequest(),
      adLoadCallback: gma.InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
          _log("AdMob Interstitial loaded.");
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isInterstitialLoading = false;
          _log("AdMob Interstitial failed to load: [${error.code}] ${error.message}");
          onFailed?.call(error.code, error.message);
        },
      ),
    );
  }

  @override
  bool isInterstitialReady() => _interstitialAd != null;

  @override
  Future<bool> showInterstitial({
    OnAdDismissed? onDismissed,
    OnAdFailedToLoad? onFailed,
    OnAdClicked? onClicked,
  }) async {
    if (_interstitialAd == null) {
      _log("AdMob Interstitial not ready to show.");
      loadInterstitial(onFailed: onFailed);
      return false;
    }

    final completer = Completer<bool>();

    _interstitialAd!.fullScreenContentCallback =
        gma.FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _log("AdMob Interstitial displayed.");
      },
      onAdClicked: (ad) {
        onClicked?.call();
      },
      onAdDismissedFullScreenContent: (ad) {
        _log("AdMob Interstitial dismissed.");
        ad.dispose();
        _interstitialAd = null;
        onDismissed?.call();
        // Automatically replenish inventory
        loadInterstitial();
        if (!completer.isCompleted) completer.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _log("AdMob Interstitial failed to show: [${error.code}] ${error.message}");
        ad.dispose();
        _interstitialAd = null;
        onFailed?.call(error.code, error.message);
        loadInterstitial();
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    await _interstitialAd!.show();
    return completer.future;
  }

  @override
  Future<void> loadRewarded({OnAdFailedToLoad? onFailed}) async {
    if (kIsWeb || !_isInitialized || _config == null) return;
    if (_rewardedAd != null || _isRewardedLoading) return;

    _isRewardedLoading = true;
    final adUnitId = _config!.adMobConfig?.getRewardedId(
          isTestMode: _config!.isTestMode,
        ) ??
        '';

    _log("Loading AdMob Rewarded ad: $adUnitId");

    await gma.RewardedAd.load(
      adUnitId: adUnitId,
      request: const gma.AdRequest(),
      rewardedAdLoadCallback: gma.RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;
          _log("AdMob Rewarded ad loaded.");
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isRewardedLoading = false;
          _log("AdMob Rewarded failed to load: [${error.code}] ${error.message}");
          onFailed?.call(error.code, error.message);
        },
      ),
    );
  }

  @override
  bool isRewardedReady() => _rewardedAd != null;

  @override
  Future<bool> showRewarded({
    required OnUserEarnedReward onUserEarnedReward,
    OnAdDismissed? onDismissed,
    OnAdFailedToLoad? onFailed,
    OnAdClicked? onClicked,
  }) async {
    if (_rewardedAd == null) {
      _log("AdMob Rewarded ad not ready to show.");
      loadRewarded(onFailed: onFailed);
      return false;
    }

    final completer = Completer<bool>();
    bool rewardEarned = false;

    _rewardedAd!.fullScreenContentCallback =
        gma.FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _log("AdMob Rewarded ad displayed.");
      },
      onAdClicked: (ad) {
        onClicked?.call();
      },
      onAdDismissedFullScreenContent: (ad) {
        _log("AdMob Rewarded ad dismissed. Reward earned: $rewardEarned");
        ad.dispose();
        _rewardedAd = null;
        onDismissed?.call();
        // Replenish inventory
        loadRewarded();
        if (!completer.isCompleted) completer.complete(rewardEarned);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _log("AdMob Rewarded ad failed to show: [${error.code}] ${error.message}");
        ad.dispose();
        _rewardedAd = null;
        onFailed?.call(error.code, error.message);
        loadRewarded();
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        rewardEarned = true;
        _log("User earned AdMob reward: ${reward.amount} ${reward.type}");
        onUserEarnedReward(reward.amount, reward.type);
      },
    );

    return completer.future;
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }

  void _log(String message) {
    if (_config?.verboseLogging ?? true) {
      debugPrint("[UniversalAds/AdMob] $message");
    }
  }
}

/// Internal stateful banner widget for AdMob.
class _AdMobBannerWidget extends StatefulWidget {
  final UniversalAdConfig config;
  final OnAdFailedToLoad? onFailed;
  final OnAdClicked? onClicked;

  const _AdMobBannerWidget({
    required this.config,
    this.onFailed,
    this.onClicked,
  });

  @override
  State<_AdMobBannerWidget> createState() => _AdMobBannerWidgetState();
}

class _AdMobBannerWidgetState extends State<_AdMobBannerWidget> {
  gma.BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _loadBanner() {
    final adUnitId = widget.config.adMobConfig?.getBannerId(
          isTestMode: widget.config.isTestMode,
        ) ??
        '';

    _bannerAd = gma.BannerAd(
      adUnitId: adUnitId,
      size: gma.AdSize.banner,
      request: const gma.AdRequest(),
      listener: gma.BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          widget.onFailed?.call(error.code, error.message);
        },
        onAdClicked: (ad) {
          widget.onClicked?.call();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded && _bannerAd != null) {
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: gma.AdWidget(ad: _bannerAd!),
      );
    }
    return const SizedBox.shrink();
  }
}
