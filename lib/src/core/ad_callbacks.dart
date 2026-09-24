/// Callback invoked when a user completes watching a rewarded video ad.
typedef OnUserEarnedReward = void Function(num amount, String type);

/// Callback invoked when a full-screen ad is closed / dismissed.
typedef OnAdDismissed = void Function();

/// Callback invoked when an ad fails to load or render.
typedef OnAdFailedToLoad = void Function(int errorCode, String message);

/// Callback invoked when an ad is clicked or opened.
typedef OnAdClicked = void Function();
