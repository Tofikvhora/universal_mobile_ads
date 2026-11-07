import 'package:flutter/widgets.dart';
import '../core/ad_callbacks.dart';
import '../core/ad_network_type.dart';
import '../manager/universal_ad_manager.dart';

/// Ready-to-use drop-in Banner Ad widget with automatic waterfall fallback.
///
/// If the primary ad network fails to fill the banner, it automatically cascades
/// to fallback networks (such as Unity Ads) seamlessly.
class UniversalBannerAd extends StatefulWidget {
  /// When true, hides the banner (e.g. for premium / Pro subscribers).
  final bool isProUser;

  /// Optional specific ad network to display. Defaults to the configured `defaultNetwork`.
  final AdNetworkType? networkType;

  /// Padding surrounding the banner ad.
  final EdgeInsetsGeometry padding;

  /// Callback when the ad fails to load.
  final OnAdFailedToLoad? onFailed;

  /// Callback when the ad is clicked.
  final OnAdClicked? onClicked;

  const UniversalBannerAd({
    super.key,
    this.isProUser = false,
    this.networkType,
    this.padding = EdgeInsets.zero,
    this.onFailed,
    this.onClicked,
  });

  @override
  State<UniversalBannerAd> createState() => _UniversalBannerAdState();
}

class _UniversalBannerAdState extends State<UniversalBannerAd> {
  late AdNetworkType _activeNetwork;
  int _fallbackIndex = 0;

  @override
  void initState() {
    super.initState();
    _activeNetwork = widget.networkType ?? UniversalMobileAds.instance.config.defaultNetwork;
  }

  void _handleBannerFailed(int code, String message) {
    widget.onFailed?.call(code, message);

    final fallbacks = UniversalMobileAds.instance.config.fallbackNetworks;
    if (_fallbackIndex < fallbacks.length) {
      final nextNetwork = fallbacks[_fallbackIndex++];
      if (mounted) {
        setState(() {
          _activeNetwork = nextNetwork;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isProUser) return const SizedBox.shrink();

    final bannerWidget = UniversalMobileAds.instance.buildBanner(
      context: context,
      networkType: _activeNetwork,
      onFailed: _handleBannerFailed,
      onClicked: widget.onClicked,
    );

    return Padding(
      padding: widget.padding,
      child: Center(
        heightFactor: 1.0,
        child: bannerWidget,
      ),
    );
  }
}
