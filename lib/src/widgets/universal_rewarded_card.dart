import 'package:flutter/material.dart';
import '../core/ad_callbacks.dart';
import '../manager/universal_ad_manager.dart';

/// Pre-styled card widget allowing users to watch a rewarded video ad to unlock features.
class UniversalRewardedCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final IconData icon;
  final Color? accentColor;
  final OnUserEarnedReward onRewardEarned;
  final VoidCallback? onFailed;

  const UniversalRewardedCard({
    super.key,
    this.title = "Watch Ad to Unlock",
    this.subtitle = "Watch a quick 15-second sponsor video to get temporary access.",
    this.buttonText = "Watch Video",
    this.icon = Icons.play_circle_fill_rounded,
    this.accentColor,
    required this.onRewardEarned,
    this.onFailed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accentColor ?? theme.colorScheme.primary;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final shown = await UniversalMobileAds.showRewardedAd(
                onUserEarnedReward: onRewardEarned,
                onFailed: (code, msg) {
                  onFailed?.call();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Ad not ready yet ($msg). Please try again shortly.")),
                  );
                },
              );
              if (!shown) {
                onFailed?.call();
              }
            },
            icon: const Icon(Icons.videocam_rounded, size: 16),
            label: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
