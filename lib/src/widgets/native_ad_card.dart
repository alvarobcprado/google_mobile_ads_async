import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_mobile_ads_async/src/widgets/native_ad_widget.dart';

/// A pre-styled widget that displays a [NativeAd] in a card-like layout.
///
/// This widget is a convenient implementation of [NativeAdWidget] that provides
/// a default layout. It can either load an ad live or display a pre-loaded ad.
class NativeAdCard extends StatelessWidget {
  /// Creates a [NativeAdCard] that loads an ad live.
  const NativeAdCard({
    required this.adUnitId,
    super.key,
    this.request,
    this.factoryId,
    this.loadingBuilder,
    this.errorBuilder,
    this.height = 320.0,
  }) : ad = null;

  /// Creates a [NativeAdCard] from a pre-loaded [NativeAd].
  const NativeAdCard.fromAd({
    required this.ad,
    super.key,
    this.factoryId,
    this.height = 320.0,
  })  : adUnitId = null,
        request = null,
        loadingBuilder = null,
        errorBuilder = null;

  /// The ad unit ID for the native ad (for live loading).
  final String? adUnitId;

  /// The pre-loaded native ad to display.
  final NativeAd? ad;

  /// The ad request to use for live loading.
  final AdRequest? request;

  /// Optional factory ID for native ad formats.
  final String? factoryId;

  /// A builder for the UI to show while the ad is loading.
  final WidgetBuilder? loadingBuilder;

  /// A builder for the UI to show when an ad fails to load.
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  /// The height of the card. Defaults to 320.
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ad != null
          ? NativeAdWidget.fromAd(
              ad!,
              factoryId: factoryId,
              nativeAdBuilder: (context, ad) => AdWidget(ad: ad),
            )
          : NativeAdWidget(
              adUnitId: adUnitId!,
              factoryId: factoryId,
              request: request,
              loadingBuilder: loadingBuilder ??
                  (context) => const Center(child: CircularProgressIndicator()),
              errorBuilder: errorBuilder ??
                  (context, error) =>
                      Center(child: Text('Failed to load ad: $error')),
              nativeAdBuilder: (context, ad) => AdWidget(ad: ad),
            ),
    );
  }
}
