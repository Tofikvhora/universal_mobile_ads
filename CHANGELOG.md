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
