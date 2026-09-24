import 'dart:io';

/// Platform-specific Ad Unit ID configurations for an ad network.
class AdNetworkConfig {
  /// Android Application ID (e.g. `ca-app-pub-YOUR_ADMOB_APP_ID`)
  final String? appIdAndroid;

  /// iOS Application ID
  final String? appIdIOS;

  /// Android Banner Ad Unit ID
  final String? bannerIdAndroid;

  /// iOS Banner Ad Unit ID
  final String? bannerIdIOS;

  /// Android Interstitial Ad Unit ID
  final String? interstitialIdAndroid;

  /// iOS Interstitial Ad Unit ID
  final String? interstitialIdIOS;

  /// Android Rewarded Video Ad Unit ID
  final String? rewardedIdAndroid;

  /// iOS Rewarded Video Ad Unit ID
  final String? rewardedIdIOS;

  /// Android App Open Ad Unit ID
  final String? appOpenIdAndroid;

  /// iOS App Open Ad Unit ID
  final String? appOpenIdIOS;

  // Official Google AdMob Test Ad Unit IDs
  static const String testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String testBannerIOS = 'ca-app-pub-3940256099942544/2934735716';

  static const String testInterstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String testInterstitialIOS = 'ca-app-pub-3940256099942544/4411468910';

  static const String testRewardedAndroid = 'ca-app-pub-3940256099942544/5224354917';
  static const String testRewardedIOS = 'ca-app-pub-3940256099942544/1712485313';

  static const String testAppOpenAndroid = 'ca-app-pub-3940256099942544/9257395921';
  static const String testAppOpenIOS = 'ca-app-pub-3940256099942544/5575463023';

  const AdNetworkConfig({
    this.appIdAndroid,
    this.appIdIOS,
    this.bannerIdAndroid,
    this.bannerIdIOS,
    this.interstitialIdAndroid,
    this.interstitialIdIOS,
    this.rewardedIdAndroid,
    this.rewardedIdIOS,
    this.appOpenIdAndroid,
    this.appOpenIdIOS,
  });

  bool _resolveIsAndroid(bool? isAndroid) {
    if (isAndroid != null) return isAndroid;
    if (Platform.isAndroid) return true;
    if (Platform.isIOS) return false;
    // In unit tests or desktop development, default to Android if Android IDs are configured
    return (bannerIdAndroid != null ||
        interstitialIdAndroid != null ||
        rewardedIdAndroid != null ||
        appIdAndroid != null);
  }

  /// Resolves the active Banner Ad Unit ID based on platform and test mode.
  String getBannerId({bool isTestMode = false, bool? isAndroid}) {
    final useAndroid = _resolveIsAndroid(isAndroid);
    if (isTestMode) {
      return useAndroid ? testBannerAndroid : testBannerIOS;
    }
    return (useAndroid ? bannerIdAndroid : bannerIdIOS) ??
        (useAndroid ? testBannerAndroid : testBannerIOS);
  }

  /// Resolves the active Interstitial Ad Unit ID based on platform and test mode.
  String getInterstitialId({bool isTestMode = false, bool? isAndroid}) {
    final useAndroid = _resolveIsAndroid(isAndroid);
    if (isTestMode) {
      return useAndroid ? testInterstitialAndroid : testInterstitialIOS;
    }
    return (useAndroid ? interstitialIdAndroid : interstitialIdIOS) ??
        (useAndroid ? testInterstitialAndroid : testInterstitialIOS);
  }

  /// Resolves the active Rewarded Video Ad Unit ID based on platform and test mode.
  String getRewardedId({bool isTestMode = false, bool? isAndroid}) {
    final useAndroid = _resolveIsAndroid(isAndroid);
    if (isTestMode) {
      return useAndroid ? testRewardedAndroid : testRewardedIOS;
    }
    return (useAndroid ? rewardedIdAndroid : rewardedIdIOS) ??
        (useAndroid ? testRewardedAndroid : testRewardedIOS);
  }

  /// Resolves the active App Open Ad Unit ID based on platform and test mode.
  String getAppOpenId({bool isTestMode = false, bool? isAndroid}) {
    final useAndroid = _resolveIsAndroid(isAndroid);
    if (isTestMode) {
      return useAndroid ? testAppOpenAndroid : testAppOpenIOS;
    }
    return (useAndroid ? appOpenIdAndroid : appOpenIdIOS) ??
        (useAndroid ? testAppOpenAndroid : testAppOpenIOS);
  }
}
