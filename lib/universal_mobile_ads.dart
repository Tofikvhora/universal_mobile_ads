/// A unified, extensible mobile advertising package for Flutter apps.
///
/// Supports Google AdMob, smart ad pacing, frequency capping, fallback waterfalls,
/// and future ad networks (Unity Ads, ironSource, AppLovin).
library;

export 'src/core/ad_callbacks.dart';
export 'src/core/ad_network_adapter.dart';
export 'src/core/ad_network_type.dart';
export 'src/core/ad_unit_id_config.dart';
export 'src/core/universal_ad_config.dart';
export 'src/manager/ad_pacing_controller.dart';
export 'src/manager/universal_ad_manager.dart';
export 'src/networks/admob_adapter.dart';
export 'src/networks/ironsource_adapter.dart';
export 'src/networks/unity_adapter.dart';
export 'src/widgets/universal_banner_ad.dart';
export 'src/widgets/universal_rewarded_card.dart';
