import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_mobile_ads_async/src/widgets/native_ad_widget.dart';

/// A pre-styled widget that displays a [NativeAd] in a card-like layout.
///
/// This widget is a convenient implementation of [NativeAdWidget] that provides
/// a default layout. It simplifies displaying a native ad by handling the
/// loading and display logic based on the provided parameters.
class NativeAdCard extends StatelessWidget {
  /// Creates a [NativeAdCard].
  ///
  /// - If [ad] is provided, it will be displayed with priority.
  /// - If [ad] is null, a new ad will be loaded using [adUnitId].
  const NativeAdCard({
    super.key,
    this.ad,
    this.adUnitId,
    this.request,
    this.factoryId,
    this.height = 320.0,
  }) : assert(
          ad != null || adUnitId != null,
          'Either a pre-loaded ad or an adUnitId must be provided.',
        );

  /// The ad unit ID for the native ad (for live loading).
  final String? adUnitId;

  /// The pre-loaded native ad to display.
  final NativeAd? ad;

  /// The ad request to use for live loading.
  final AdRequest? request;

  /// Optional factory ID for native ad formats.
  final String? factoryId;

  /// The height of the card. Defaults to 320.
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: NativeAdWidget(
        ad: ad,
        adUnitId: adUnitId,
        factoryId: factoryId,
        adRequest: request ?? const AdRequest(),
        nativeAdBuilder: (context, ad) => AdWidget(ad: ad),
      ),
    );
  }
}
