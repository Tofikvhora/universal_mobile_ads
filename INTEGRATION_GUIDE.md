# Universal Mobile Ads — Complete Integration & Architecture Guide

A step-by-step handbook on how this plugin works and how to integrate it into **any new or existing Flutter app** in under 5 minutes.

---

## 1. What Does This Plugin Do? (In Simple Words)

Normally, handling ads in Flutter requires writing lots of repetitive boilerplate:
- Setting up Google Mobile Ads SDK.
- Manually loading and disposing Banner, Interstitial, and Rewarded ads.
- Worrying about your AdMob account getting banned if you accidentally show real ads during testing.
- Writing custom code to track how many times a user tapped something before showing an ad.
- Writing cooldown timers so ads don't pop up every 2 seconds.
- Suppressing ads for users who bought the PRO / Paid version.
- Switching to other networks (Unity, ironSource) if AdMob runs out of ads.

**`universal_mobile_ads` solves all of this automatically in one unified package.**

```
+---------------------------------------------------------------------------------+
|                                 YOUR FLUTTER APP                                 |
+---------------------------------------------------------------------------------+
                                         |
                                         v
+---------------------------------------------------------------------------------+
|                          UniversalMobileAds (Facade)                            |
|   - Smart Pacing (e.g. 1 ad per 3 actions)     - Pro User Auto-Suppression      |
|   - Cooldown Timers (e.g. 15s between ads)     - Auto Test IDs in Debug Mode    |
|   - Persistent State Across Restarts           - Waterfall Network Fallbacks    |
+---------------------------------------------------------------------------------+
                                         |
             +---------------------------+---------------------------+
             v                                                       v
+-------------------------+                             +-------------------------+
|      AdMobAdapter       |                             |     Unity / ironSource  |
|  (Official Google SDK)  |                             |   (Fallback Waterfall)  |
+-------------------------+                             +-------------------------+
```

---

## 2. The 3 Core Superpowers

### Superpower A: Safe Test-Mode Switch (Zero Risk of Invalid Traffic Ban)
- When `isTestMode: true` (e.g. in `kDebugMode`), the plugin **automatically swaps in Google's official public test IDs** for Banners, Interstitials, and Rewarded ads.
- When `isTestMode: false` (Release mode), it automatically uses your real production ad unit IDs.
- You never have to worry about accidentally clicking a real ad on your test device!

### Superpower B: Smart Pacing & Frequency Capping
- **Action Counter**: You call `UniversalMobileAds.recordAction()` whenever a user does something (e.g. adds an item, finishes a level, saves a note).
- **Minimum Actions**: It will only show an interstitial after $N$ actions (e.g. after every 3 actions).
- **Cooldown Interval**: It enforces a time delay (e.g. 15–30 seconds) between interstitials so users never feel spammed.
- **Persistence**: Remembers where the user was even if they close and restart the app.

### Superpower C: 1-Line Pro User Protection
- Pass `isProUser: true` to any ad widget or display call.
- The plugin **instantly and completely suppresses** banners and interstitials for paid customers.

---

## 3. How to Add This Plugin to ANY New Flutter App

### Step 1: Add Dependency to `pubspec.yaml`

In your new app's `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  # From pub.dev:
  universal_mobile_ads: ^1.0.1
```

*(Or locally while testing)*:
```yaml
dependencies:
  universal_mobile_ads:
    path: F:/Flutter plugin/universal_mobile_ads
```

Run in terminal:
```bash
flutter pub get
```

---

### Step 2: Native Android & iOS Setup

#### Android Setup (`android/app/src/main/AndroidManifest.xml`)
Add your AdMob App ID inside the `<application>` tag:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application ...>
        <!-- Google AdMob Application ID -->
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-YOUR_ADMOB_APP_ID"/>
    </application>
</manifest>
```

#### iOS Setup (`ios/Runner/Info.plist`)
Add your AdMob App ID inside `<dict>`:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-YOUR_ADMOB_APP_ID</string>
<key>SKAdNetworkItems</key>
<array>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>cstr6suwn9.skadnetwork</string>
  </dict>
</array>
```

---

### Step 3: Initialize in `main()`

Initialize `UniversalMobileAds` once at app startup in your `lib/main.dart`:

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_mobile_ads/universal_mobile_ads.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. (Optional) Load saved action count from SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final savedCount = prefs.getInt('ad_action_count') ?? 0;

  // 2. Configure Ad Networks & IDs
  final adConfig = UniversalAdConfig(
    defaultNetwork: AdNetworkType.admob,
    isTestMode: kDebugMode, // Automatically uses Google test IDs during debug!
    interstitialMinActions: 3, // Show interstitial after 3 user actions
    interstitialCooldown: const Duration(seconds: 20), // 20s minimum gap
    adMobConfig: const AdNetworkConfig(
      appIdAndroid: 'ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX',
      bannerIdAndroid: 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX',
      interstitialIdAndroid: 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX',
      rewardedIdAndroid: 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX',
    ),
  );

  // 3. Initialize the plugin
  await UniversalMobileAds.initialize(
    config: adConfig,
    initialActionCount: savedCount,
    onCounterChanged: (count) async {
      // Automatically persist counter across app restarts!
      final p = await SharedPreferences.getInstance();
      await p.setInt('ad_action_count', count);
    },
  );

  runApp(const MyApp());
}
```

---

## 4. How to Use Ads in Your App Screens

### A. Showing a Banner Ad (Simple Widget)

Just drop `UniversalBannerAd` anywhere in your widget tree (e.g. at the bottom of a screen):

```dart
import 'package:universal_mobile_ads/universal_mobile_ads.dart';

class HomeScreen extends StatelessWidget {
  final bool isProUser; // From your state management or auth

  const HomeScreen({super.key, required this.isProUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My App')),
      body: Center(child: Text('Main Content')),
      bottomNavigationBar: UniversalBannerAd(
        isProUser: isProUser, // If true, widget collapses to 0 height!
        padding: const EdgeInsets.symmetric(vertical: 4),
      ),
    );
  }
}
```

---

### B. Showing Paced Interstitial Ads (Between Actions)

Whenever the user logs an entry, submits a form, or completes a level:

```dart
void onUserCompletedAction(bool isProUser) {
  // 1. Record the action (+1 to counter)
  UniversalMobileAds.recordAction();

  // 2. Check if conditions are met (>= 3 actions + 20s elapsed + not Pro)
  if (UniversalMobileAds.canShowInterstitial(isProUser: isProUser)) {
    UniversalMobileAds.showPacedInterstitial(
      isProUser: isProUser,
      onAdDismissed: () {
        // Continue to next screen or action
        navigateToNextScreen();
      },
    );
  } else {
    // Ad was not ready or conditions not met - proceed immediately
    navigateToNextScreen();
  }
}
```

---

### C. Showing Rewarded Video Ads (Watch to Unlock a Feature)

When the user taps "Watch Ad to Unlock Pro Feature for 24 Hours":

```dart
Future<void> onWatchRewardAdPressed() async {
  final bool watched = await UniversalMobileAds.showRewardedAd(
    onUserEarnedReward: (amount, type) {
      // User finished watching the video! Grant them access:
      grantRewardToUser();
    },
    onFailed: (code, message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ad not ready: $message')),
      );
    },
  );

  if (!watched) {
    debugPrint('Rewarded ad was not watched or failed to show.');
  }
}
```

---

### D. Using the Built-In Rewarded Card UI Widget

If you want a stylish, ready-made card for your paywall or settings screen:

```dart
UniversalRewardedCard(
  title: 'Unlock Statement Export',
  description: 'Watch a short 15-second sponsor video to unlock free PDF export for today.',
  buttonText: 'Watch Video Ad',
  icon: Icons.play_circle_fill_rounded,
  onUserEarnedReward: () {
    // Unlock export feature
    unlockPdfExport();
  },
)
```

---

## 5. Summary Cheat-Sheet

| What you want to do | Method / Widget to use |
|---|---|
| **Initialize ads at startup** | `UniversalMobileAds.initialize(config: ...)` |
| **Show Banner at bottom** | `UniversalBannerAd(isProUser: isPro)` |
| **Increment action counter** | `UniversalMobileAds.recordAction()` |
| **Check if interstitial can show** | `UniversalMobileAds.canShowInterstitial(isProUser: isPro)` |
| **Show interstitial ad** | `UniversalMobileAds.showPacedInterstitial(isProUser: isPro)` |
| **Show rewarded ad** | `UniversalMobileAds.showRewardedAd(onUserEarnedReward: ...)` |
| **Card UI for rewarded video** | `UniversalRewardedCard(...)` |

You can now drop `universal_mobile_ads` into **any Flutter app** and get production-grade AdMob ads, intelligent pacing, and pro user protection in minutes!
