import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../ad_loader.dart';
import 'ad_widget_wrapper.dart';

/// A builder function that creates a widget to display a [NativeAd].
typedef NativeAdBuilder = Widget Function(BuildContext context, NativeAd ad);

/// A widget that loads and displays a [NativeAd].
///
/// This widget simplifies the integration of native ads by managing the ad
/// lifecycle automatically. It provides a [nativeAdBuilder] to allow for

/// a completely custom UI for the loaded ad.
class NativeAdWidget extends AdWidgetWrapper<NativeAd> {
  /// A builder function to create the widget that displays the native ad.
  ///
  /// This gives you full control over the ad's layout.
  final NativeAdBuilder nativeAdBuilder;

  /// Optional factory ID for native ad formats.
  final String? factoryId;

  /// Creates a [NativeAdWidget].
  ///
  /// - [adUnitId]: The ad unit ID for the native ad.
  /// - [nativeAdBuilder]: The builder function to create the ad's UI.
  /// - [factoryId]: An optional factory ID.
  /// - [request]: The ad request to use.
  /// - [loadingBuilder]: A builder for the UI to show while the ad is loading.
  /// - [errorBuilder]: A builder for the UI to show when an ad fails to load.
  /// - [adLoader]: An optional [AsyncAdLoader] to use for loading the ad.
  const NativeAdWidget({
    super.key,
    required super.adUnitId,
    required this.nativeAdBuilder,
    this.factoryId,
    super.request,
    super.loadingBuilder,
    super.errorBuilder,
    super.adLoader,
  });

  @override
  Future<NativeAd> loadAd() {
    final loader = adLoader ?? AsyncAdLoader();
    return loader.loadNativeAd(
      adUnitId: adUnitId,
      request: request,
      factoryId: factoryId,
    );
  }

  @override
  Widget buildAd(BuildContext context, NativeAd ad) {
    return nativeAdBuilder(context, ad);
  }
}
