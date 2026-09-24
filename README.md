# Universal Mobile Ads 📱

[![pub package](https://img.shields.io/pub/v/universal_mobile_ads.svg)](https://pub.dev/packages/universal_mobile_ads)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A unified, multi-platform mobile advertising package for Flutter. Built from the ground up to support **Google AdMob**, smart ad pacing, waterfall fallbacks, and pluggable support for future networks like **Unity Ads** and **ironSource**—all without hardcoding ad IDs or duplicating logic across your apps.

---

## ✨ Features

- 🎯 **No Hardcoding**: Configure your Ad Units once in your app configuration; the package manages IDs, lifecycles, and platform switches dynamically.
- 🛡️ **Built-in Safe Test Mode**: When `isTestMode: true` (e.g. in `kDebugMode`), official Google test ad units are served automatically to protect your AdMob account from invalid traffic penalties.
- ⏱️ **Smart Ad Pacing & Frequency Capping**: Prevents ad fatigue by enforcing minimum actions (e.g., show ad every 3 actions) and cooldown timers (e.g., minimum 15s between interstitials).
- 👑 **Pro User Protection**: Automatic zero-ad suppression for premium/Pro subscribers.
- 🌊 **Waterfall Fallback Ready**: If the primary network (AdMob) has no fill, it automatically falls back to secondary networks (Unity Ads, ironSource).
- 🧩 **Pluggable Architecture**: Easily register custom ad networks or future SDK adapters without changing application UI code.
- 🧱 **Drop-in Widgets**: Simple `UniversalBannerAd` and `UniversalRewardedCard` widgets ready to drop into any screen.

---

## 🚀 Getting Started

### 1. Add Dependency

Add `universal_mobile_ads` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  universal_mobile_ads: ^1.0.0
```

### 2. Platform Setup

#### Android (`android/app/src/main/AndroidManifest.xml`)
Add your AdMob App ID inside the `<application>` tag:

```xml
<manifest>
    <application ...>
        <!-- Replace with your actual AdMob App ID -->
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-2752141161169735~8091085841"/>
    </application>
</manifest>
```

#### iOS (`ios/Runner/Info.plist`)
Add your AdMob App ID inside `<dict>`:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-2752141161169735~8091085841</string>
<key>SKAdNetworkItems</key>
<array>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>cstr6suwn9.skadnetwork</string>
  </dict>
</array>
```

---

## 📖 Usage

### 1. Initialize at App Launch

Call `UniversalMobileAds.initialize()` in your `main()` before running the app:

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:universal_mobile_ads/universal_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await UniversalMobileAds.initialize(
    config: const UniversalAdConfig(
      defaultNetwork: AdNetworkType.admob,
      fallbackNetworks: [
        AdNetworkType.unity,
        AdNetworkType.ironSource,
      ],
      // Automatically serves Google test ad units during debug / development
      isTestMode: kDebugMode,
      adMobConfig: AdNetworkConfig(
        appIdAndroid: 'ca-app-pub-2752141161169735~8091085841',
        bannerIdAndroid: 'ca-app-pub-2752141161169735/9999063888',
        interstitialIdAndroid: 'ca-app-pub-2752141161169735/7642247873',
        rewardedIdAndroid: 'ca-app-pub-2752141161169735/4866156708',
      ),
      // Pacing rules: show ad every 3 actions with a 15-second cooldown
      interstitialCooldown: Duration(seconds: 15),
      interstitialMinActions: 3,
    ),
    // Optional: hook to save action counter across app restarts (e.g. SharedPreferences)
    initialActionCount: 0,
    onCounterChanged: (count) {
      // save count to local storage
    },
  );

  runApp(const MyApp());
}
```

---

### 2. Display a Banner Ad

Place `UniversalBannerAd` anywhere in your widget tree:

```dart
// Standard banner
const UniversalBannerAd()

// Banner with Pro-user check and padding
UniversalBannerAd(
  isProUser: isUserProSubscriber,
  padding: const EdgeInsets.symmetric(vertical: 8),
)
```

---

### 3. Show Paced Interstitial Ads

Track user actions (e.g., adding an expense, finishing a level, clicking a button) and show interstitials automatically when pacing criteria are met:

```dart
// Step 1: Record an action
UniversalMobileAds.recordAction();

// Step 2: Request an interstitial ad
// If the user is Pro, or hasn't reached 3 actions, or is on cooldown, this safely skips without showing an ad.
await UniversalMobileAds.showPacedInterstitial(
  isProUser: isUserProSubscriber,
  onAdDismissed: () {
    // Proceed to next screen
  },
);
```

---

### 4. Show Rewarded Video Ads

Prompt users to watch a rewarded video ad to unlock temporary passes or premium items:

```dart
await UniversalMobileAds.showRewardedAd(
  onUserEarnedReward: (amount, type) {
    // Grant reward (e.g. unlock 24-hour pass, grant 50 coins)
    print("User earned reward: $amount $type");
  },
  onFailed: (errorCode, message) {
    print("Ad failed: $message");
  },
);
```

Or use the pre-built `UniversalRewardedCard` widget:

```dart
UniversalRewardedCard(
  title: "Unlock 24h Premium Pass",
  subtitle: "Watch a quick sponsor video to access exports.",
  onRewardEarned: (amount, type) {
    unlockFeature();
  },
)
```

---

### 5. Adding Future Ad Networks (Unity Ads, ironSource, etc.)

When you are ready to expand to Unity Ads, ironSource, or AppLovin MAX:
1. Provide their configurations in `UniversalAdConfig(unityConfig: ..., ironSourceConfig: ...)`.
2. Add your custom adapter or import the platform adapter via `UniversalMobileAds.instance.registerAdapter(MyCustomAdapter())`.
3. Your UI code and widgets remain **100% unchanged**!

---

## 🛠️ Verification & Tests

Run the test suite to verify that all pacing and unit configuration rules work properly:

```bash
flutter test
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
