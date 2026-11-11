## 1.1.1

* **Unity Ads Async Callback Resolution**: Fixed `UnityAdsAdapter` (`initialize`, `loadInterstitial`, `showInterstitial`, `loadRewarded`, and `showRewarded`) to await asynchronous `UnityAds` platform callbacks using `Completer<bool>`, ensuring accurate load state and reward completion before resolving.
* **Improved Interstitial Waterfall Fallback**: Updated `UniversalAdManager.canShowInterstitial` and `showInterstitial` to check both primary and fallback adapters (`AdMob -> Unity Ads`) without firing failure callbacks prematurely when the primary network has no fill.
* **Gradle 9 Compatibility**: Widened `google_mobile_ads` constraint (`>=5.2.0 <10.0.0`) so projects using Gradle 9+ resolve compatible `google_mobile_ads` releases without `configurations.all` build errors.

## 1.1.0

* **Unity Ads Support**: Added full production adapter for Unity Ads via `unity_ads_plugin`.
* **Automatic Waterfall Fallback**: Automatically cascades to fallback networks (like Unity Ads) when the primary network (AdMob) is unavailable, fails to load, or has no fill.
* **Smart Banner Fallback**: `UniversalBannerAd` now automatically swaps to fallback network banners if the primary banner network fails to fill.
* **Pre-warming & Dual Initialization**: Automatically pre-warms both primary and configured fallback networks on start for instantaneous ad displays.

## 1.0.1

* Replaced sample documentation AdMob IDs with generic placeholders and official Google demo ad units.
* Updated code documentation examples to use generic placeholders.

## 1.0.0

* Initial release of `universal_mobile_ads`.
* Full integration with Google AdMob (`google_mobile_ads`).
* Pluggable architecture ready for Unity Ads and ironSource mediation.
* Automatic official Google test ad unit resolution when `isTestMode` is enabled.
* Smart ad pacing and frequency capping with cooldown intervals and minimum action counts.
* Automatic ad suppression for Pro / premium users.
* Easy-to-use UI widgets: `UniversalBannerAd` and `UniversalRewardedCard`.
* Fallback waterfall: automatically falls back to secondary ad networks if primary network returns no fill.
