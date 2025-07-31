import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_mobile_ads_async/src/ad_loader.dart';
import 'package:google_mobile_ads_async/src/widgets/ad_widget_wrapper.dart';

/// A builder function that creates a widget to display a [NativeAd].
typedef NativeAdBuilder = Widget Function(BuildContext context, NativeAd ad);

/// A widget that loads and displays a [NativeAd].
///
/// This widget can either load an ad live or display a pre-loaded ad
/// provided via the [NativeAdWidget.fromAd] constructor.
class NativeAdWidget extends AdWidgetWrapper<NativeAd> {
  /// Creates a [NativeAdWidget] that loads an ad live.
  ///
  /// - [adUnitId]: The ad unit ID for the native ad.
  /// - [nativeAdBuilder]: The builder function to create the ad's UI.
  /// - [factoryId]: An optional factory ID.
  /// - [request]: The ad request to use.
  /// - [loadingBuilder]: A builder for the UI to show while the ad is loading.
  /// - [errorBuilder]: A builder for the UI to show when an ad fails to load.
  /// - [adLoader]: An optional [AsyncAdLoader] to use for loading the ad.
  const NativeAdWidget({
    required String adUnitId,
    required this.nativeAdBuilder,
    super.key,
    this.factoryId,
    super.request,
    super.loadingBuilder,
    super.errorBuilder,
    super.adLoader,
  }) : super(adUnitId: adUnitId);

  /// Creates a [NativeAdWidget] from a pre-loaded [NativeAd].
  NativeAdWidget.fromAd(
    NativeAd ad, {
    required this.nativeAdBuilder,
    super.key,
    this.factoryId,
  }) : super.fromAd(ad: ad);

  /// A builder function to create the widget that displays the native ad.
  ///
  /// This gives you full control over the ad's layout.
  final NativeAdBuilder nativeAdBuilder;

  /// Optional factory ID for native ad formats.
  final String? factoryId;

  @override
  Future<NativeAd> loadAd() {
    final loader = adLoader ?? AsyncAdLoader();
    return loader.loadNativeAd(
      adUnitId: adUnitId!,
      request: request,
      factoryId: factoryId,
    );
  }

  @override
  Widget buildAd(BuildContext context, NativeAd ad) {
    return nativeAdBuilder(context, ad);
  }
}
