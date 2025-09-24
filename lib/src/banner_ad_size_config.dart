import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// {@template banner_ad_size_config}
/// Configuration for specifying the size of a banner ad.
///
/// This class allows for both standard [AdSize] and adaptive banner
/// configurations.
/// {@endtemplate}
class BannerAdSizeConfig {
  /// {@macro banner_ad_size_config}
  /// Creates a configuration for an inline adaptive banner.
  const BannerAdSizeConfig.inline({
    this.padding = EdgeInsets.zero,
    this.maxHeight,
  })  : size = null,
        isInlineAdaptive = true;

  /// {@macro banner_ad_size_config}
  /// Creates a configuration for an anchored adaptive banner.
  const BannerAdSizeConfig.anchored({
    this.padding = EdgeInsets.zero,
  })  : size = null,
        maxHeight = null,
        isInlineAdaptive = false;

  /// {@macro banner_ad_size_config}
  /// Creates a configuration for a standard banner using a predefined [AdSize].
  const BannerAdSizeConfig.standard(AdSize this.size)
      : maxHeight = null,
        isInlineAdaptive = null,
        padding = EdgeInsets.zero;

  /// The standard [AdSize] for non-adaptive banners.
  final AdSize? size;

  /// The maximum height for an inline adaptive banner (optional).
  final double? maxHeight;

  /// Whether this is an inline adaptive banner. Null for standard banners.
  final bool? isInlineAdaptive;

  /// The padding around the banner ad, used to calculate the ad's width.
  final EdgeInsets padding;

  /// Calculates the appropriate [AdSize] based on the configuration.
  ///
  /// Returns `null` if the configuration is invalid or cannot determine an
  /// [AdSize].
  Future<AdSize?> getAdSize(BuildContext context) async {
    if (size != null) {
      return size;
    }

    if (isInlineAdaptive != null) {
      final mediaQueryWidth = MediaQuery.sizeOf(context).width;
      final adWidth = mediaQueryWidth - padding.horizontal;

      if (adWidth < 0) {
        return null; // Invalid width after applying padding
      }

      if (isInlineAdaptive!) {
        // Inline adaptive banner
        if (maxHeight != null) {
          return AdSize.getInlineAdaptiveBannerAdSize(
            adWidth.toInt(),
            maxHeight!.toInt(),
          );
        } else {
          return AdSize.getCurrentOrientationInlineAdaptiveBannerAdSize(
            adWidth.toInt(),
          );
        }
      } else {
        // Anchored adaptive banner
        return AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
          adWidth.toInt(),
        );
      }
    }
    return null;
  }
}
