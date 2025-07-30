import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../ad_loader.dart';
import 'ad_widget_wrapper.dart';

/// A widget that loads and displays a [BannerAd].
///
/// This widget simplifies the integration of banner ads by managing the ad
/// lifecycle automatically. It can either load an ad live or display a
/// pre-loaded ad provided via the [BannerAdWidget.fromAd] constructor.
class BannerAdWidget extends AdWidgetWrapper<BannerAd> {
  /// The size of the banner ad.
  final AdSize size;

  /// Creates a [BannerAdWidget] that loads an ad live.
  ///
  /// - [adUnitId]: The ad unit ID for the banner ad.
  /// - [size]: The size of the banner ad (e.g., [AdSize.banner]).
  /// - [request]: The ad request to use.
  /// - [loadingBuilder]: A builder for the UI to show while the ad is loading.
  /// - [errorBuilder]: A builder for the UI to show when an ad fails to load.
  /// - [adLoader]: An optional [AsyncAdLoader] to use for loading the ad.
  const BannerAdWidget({
    super.key,
    required String adUnitId,
    required this.size,
    super.request,
    super.loadingBuilder,
    super.errorBuilder,
    super.adLoader,
  }) : super(adUnitId: adUnitId);

  /// Creates a [BannerAdWidget] from a pre-loaded [BannerAd].
  ///
  /// This is useful when you have already loaded an ad, for example,
  /// using [AdCacheManager].
  BannerAdWidget.fromAd(
    BannerAd ad, {
    super.key,
  })  : size = ad.size,
        super.fromAd(ad: ad);

  @override
  Future<BannerAd> loadAd() {
    final loader = adLoader ?? AsyncAdLoader();
    return loader.loadBannerAd(
      adUnitId: adUnitId!,
      size: size,
      request: request,
    );
  }

  @override
  Widget buildAd(BuildContext context, BannerAd ad) {
    return SizedBox(
      width: size.width.toDouble(),
      height: size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}
