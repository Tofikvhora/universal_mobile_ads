import 'package:flutter_test/flutter_test.dart';
import 'package:universal_mobile_ads/universal_mobile_ads.dart';

void main() {
  group('AdNetworkConfig Tests', () {
    test('Resolves test ad units in test mode', () {
      const config = AdNetworkConfig(
        bannerIdAndroid: 'ca-app-pub-2752141161169735/9999063888',
        interstitialIdAndroid: 'ca-app-pub-2752141161169735/7642247873',
        rewardedIdAndroid: 'ca-app-pub-2752141161169735/4866156708',
      );

      // In test mode, it must return official Google test unit IDs
      expect(config.getBannerId(isTestMode: true), AdNetworkConfig.testBannerAndroid);
      expect(config.getInterstitialId(isTestMode: true), AdNetworkConfig.testInterstitialAndroid);
      expect(config.getRewardedId(isTestMode: true), AdNetworkConfig.testRewardedAndroid);
    });

    test('Resolves production ad units in production mode', () {
      const config = AdNetworkConfig(
        bannerIdAndroid: 'ca-app-pub-2752141161169735/9999063888',
        interstitialIdAndroid: 'ca-app-pub-2752141161169735/7642247873',
        rewardedIdAndroid: 'ca-app-pub-2752141161169735/4866156708',
      );

      expect(config.getBannerId(isTestMode: false), 'ca-app-pub-2752141161169735/9999063888');
      expect(config.getInterstitialId(isTestMode: false), 'ca-app-pub-2752141161169735/7642247873');
      expect(config.getRewardedId(isTestMode: false), 'ca-app-pub-2752141161169735/4866156708');
    });
  });

  group('AdPacingController Tests', () {
    test('Respects minimum action count before showing ad', () {
      final controller = AdPacingController(
        minActions: 3,
        cooldown: const Duration(seconds: 15),
      );

      expect(controller.actionsSinceLastAd, 0);
      expect(controller.canShowInterstitial(isProUser: false), false);

      controller.recordAction(); // 1
      expect(controller.canShowInterstitial(isProUser: false), false);

      controller.recordAction(); // 2
      expect(controller.canShowInterstitial(isProUser: false), false);

      controller.recordAction(); // 3
      expect(controller.canShowInterstitial(isProUser: false), true);
    });

    test('Pro users NEVER see interstitial ads', () {
      final controller = AdPacingController(
        minActions: 1,
        cooldown: Duration.zero,
      );

      controller.recordAction();
      controller.recordAction();

      // Non-pro user can see ad
      expect(controller.canShowInterstitial(isProUser: false), true);

      // Pro user CANNOT see ad
      expect(controller.canShowInterstitial(isProUser: true), false);
    });

    test('Cooldown duration prevents rapid consecutive ads', () {
      final controller = AdPacingController(
        minActions: 1,
        cooldown: const Duration(minutes: 5),
      );

      controller.recordAction();
      expect(controller.canShowInterstitial(isProUser: false), true);

      // Simulate ad shown
      controller.recordAdShown();
      expect(controller.actionsSinceLastAd, 0);

      // Immediately record another action
      controller.recordAction();
      // Counter is 1, but cooldown of 5 minutes is active!
      expect(controller.canShowInterstitial(isProUser: false), false);
    });

    test('Persistence hook notifies on count change', () {
      int recordedState = -1;
      final controller = AdPacingController(
        minActions: 3,
        onCounterChanged: (count) {
          recordedState = count;
        },
      );

      controller.recordAction();
      expect(recordedState, 1);

      controller.recordAction();
      expect(recordedState, 2);

      controller.recordAdShown();
      expect(recordedState, 0);
    });
  });

  group('UniversalAdConfig & Manager Setup', () {
    test('Initializes with custom ad units and defaults', () {
      const config = UniversalAdConfig(
        defaultNetwork: AdNetworkType.admob,
        fallbackNetworks: [AdNetworkType.unity, AdNetworkType.ironSource],
        isTestMode: true,
        adMobConfig: AdNetworkConfig(
          appIdAndroid: 'ca-app-pub-2752141161169735~8091085841',
          bannerIdAndroid: 'ca-app-pub-2752141161169735/9999063888',
        ),
      );

      expect(config.defaultNetwork, AdNetworkType.admob);
      expect(config.fallbackNetworks.length, 2);
      expect(config.isTestMode, true);
      expect(config.adMobConfig?.appIdAndroid, 'ca-app-pub-2752141161169735~8091085841');
      expect(config.getConfigFor(AdNetworkType.admob), isNotNull);
      expect(config.getConfigFor(AdNetworkType.unity), isNull);
    });
  });
}
