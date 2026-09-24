import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:universal_mobile_ads/universal_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Universal Mobile Ads once at app startup
  await UniversalMobileAds.initialize(
    config: const UniversalAdConfig(
      defaultNetwork: AdNetworkType.admob,
      fallbackNetworks: [
        AdNetworkType.unity,
        AdNetworkType.ironSource,
      ],
      // Use test ads in debug mode; uses production IDs in release mode
      isTestMode: kDebugMode,
      adMobConfig: AdNetworkConfig(
        appIdAndroid: 'ca-app-pub-3940256099942544~3347511713',
        bannerIdAndroid: AdNetworkConfig.testBannerAndroid,
        interstitialIdAndroid: AdNetworkConfig.testInterstitialAndroid,
        rewardedIdAndroid: AdNetworkConfig.testRewardedAndroid,
      ),
      interstitialCooldown: Duration(seconds: 15),
      interstitialMinActions: 3,
      verboseLogging: true,
    ),
    initialActionCount: 0,
    onCounterChanged: (count) {
      debugPrint("[ExampleApp] Actions counter updated to: $count");
    },
  );

  runApp(const UniversalAdsExampleApp());
}

class UniversalAdsExampleApp extends StatelessWidget {
  const UniversalAdsExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Universal Mobile Ads Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      home: const DemoHomeScreen(),
    );
  }
}

class DemoHomeScreen extends StatefulWidget {
  const DemoHomeScreen({super.key});

  @override
  State<DemoHomeScreen> createState() => _DemoHomeScreenState();
}

class _DemoHomeScreenState extends State<DemoHomeScreen> {
  bool _isProUser = false;
  int _rewardPassHours = 0;

  void _recordAction() {
    UniversalMobileAds.recordAction();
    setState(() {});
  }

  Future<void> _attemptInterstitial() async {
    final shown = await UniversalMobileAds.showPacedInterstitial(
      isProUser: _isProUser,
      onAdDismissed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Interstitial Ad closed.")),
        );
      },
    );

    if (!shown && mounted) {
      final pacing = UniversalMobileAds.instance.pacing;
      final needed = UniversalMobileAds.instance.config.interstitialMinActions;
      final current = pacing.actionsSinceLastAd;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isProUser
                ? "Pro users don't see ads!"
                : "Pacing active: Need $needed actions (current: $current) or cooldown active.",
          ),
        ),
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final pacing = UniversalMobileAds.instance.pacing;
    final minActions = UniversalMobileAds.instance.config.interstitialMinActions;
    final currentActions = pacing.actionsSinceLastAd;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Universal Mobile Ads"),
        actions: [
          Row(
            children: [
              const Text("PRO", style: TextStyle(fontWeight: FontWeight.bold)),
              Switch(
                value: _isProUser,
                onChanged: (val) => setState(() => _isProUser = val),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner Ad Demo
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("1. Universal Banner Ad",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  UniversalBannerAd(
                    isProUser: _isProUser,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Pacing & Interstitial Demo
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("2. Smart Paced Interstitials",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text("Actions: $currentActions / $minActions required"),
                  LinearProgressIndicator(
                    value: (currentActions / minActions).clamp(0.0, 1.0),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _recordAction,
                        icon: const Icon(Icons.touch_app_rounded),
                        label: const Text("Record Action (+1)"),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: _attemptInterstitial,
                        icon: const Icon(Icons.fullscreen_rounded),
                        label: const Text("Show Interstitial"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Rewarded Ad Demo
          UniversalRewardedCard(
            title: "Watch Ad for 24h Pass",
            subtitle: _rewardPassHours > 0
                ? "Active Pass: $_rewardPassHours hours remaining!"
                : "Watch a quick sponsor video to unlock premium export features.",
            buttonText: "Watch Video",
            onRewardEarned: (amount, type) {
              setState(() {
                _rewardPassHours += 24;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("🎉 24-Hour Pass Unlocked!")),
              );
            },
          ),
        ],
      ),
    );
  }
}
