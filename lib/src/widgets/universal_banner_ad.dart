import 'package:flutter/widgets.dart';
import '../core/ad_callbacks.dart';
import '../core/ad_network_type.dart';
import '../manager/universal_ad_manager.dart';

/// Ready-to-use drop-in Banner Ad widget.
///
/// Automatically respects Pro status and renders a responsive banner ad.
class UniversalBannerAd extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (isProUser) return const SizedBox.shrink();

    final bannerWidget = UniversalMobileAds.instance.buildBanner(
      context: context,
      networkType: networkType,
      onFailed: onFailed,
      onClicked: onClicked,
    );

    return Padding(
      padding: padding,
      child: Center(child: bannerWidget),
    );
  }
}
