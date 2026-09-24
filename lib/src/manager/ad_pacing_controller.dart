/// Controls frequency capping, cooldown intervals, and Pro-user ad suppression.
class AdPacingController {
  final Duration cooldown;
  final int minActions;

  DateTime? _lastInterstitialTime;
  int _actionsSinceLastAd = 0;

  /// Optional listener notified whenever the action counter changes,
  /// allowing host apps to persist the count to local storage.
  final void Function(int actionsCount)? onCounterChanged;

  AdPacingController({
    this.cooldown = const Duration(seconds: 15),
    this.minActions = 3,
    int initialActionCount = 0,
    this.onCounterChanged,
  }) : _actionsSinceLastAd = initialActionCount;

  /// Current action count accumulated since last interstitial ad.
  int get actionsSinceLastAd => _actionsSinceLastAd;

  /// Timestamp of the most recent interstitial impression.
  DateTime? get lastInterstitialTime => _lastInterstitialTime;

  /// Records a user action (e.g. adding a transaction, completing a task).
  void recordAction() {
    _actionsSinceLastAd++;
    onCounterChanged?.call(_actionsSinceLastAd);
  }

  /// Sets the action counter directly (useful when restoring from persistent storage).
  void setActionCount(int count) {
    _actionsSinceLastAd = count;
  }

  /// Evaluates whether an interstitial ad is eligible to display based on pacing rules.
  bool canShowInterstitial({bool isProUser = false}) {
    // 1. Pro / Paid users NEVER see interstitial ads
    if (isProUser) return false;

    // 2. Minimum action count check
    if (_actionsSinceLastAd < minActions) return false;

    // 3. Cooldown duration check
    if (_lastInterstitialTime != null) {
      final elapsed = DateTime.now().difference(_lastInterstitialTime!);
      if (elapsed < cooldown) return false;
    }

    return true;
  }

  /// Resets the counter and sets the impression timestamp.
  void recordAdShown() {
    _lastInterstitialTime = DateTime.now();
    _actionsSinceLastAd = 0;
    onCounterChanged?.call(0);
  }
}
