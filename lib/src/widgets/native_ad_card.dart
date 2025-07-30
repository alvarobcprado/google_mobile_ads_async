import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../ad_loader.dart';
import 'native_ad_widget.dart';

/// A pre-styled widget that displays a [NativeAd] in a card-like layout.
///
/// This widget is a convenient implementation of [NativeAdWidget] that provides
/// a default layout. It handles loading and displays the ad in a fixed-height
/// container.
class NativeAdCard extends StatelessWidget {
  /// The ad unit ID for the native ad.
  final String adUnitId;

  /// The ad request to use.
  final AdRequest? request;

  /// Optional factory ID for native ad formats.
  final String? factoryId;

  /// A builder for the UI to show while the ad is loading.
  ///
  /// If null, a [CircularProgressIndicator] is shown.
  final WidgetBuilder? loadingBuilder;

  /// A builder for the UI to show when an ad fails to load.
  ///
  /// If null, a simple error message is shown.
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  /// The height of the card. Defaults to 320.
  final double height;

  /// An optional [AsyncAdLoader] to use for loading the ad.
  final AsyncAdLoader? adLoader;

  /// Creates a [NativeAdCard].
  const NativeAdCard({
    super.key,
    required this.adUnitId,
    this.request,
    this.factoryId,
    this.loadingBuilder,
    this.errorBuilder,
    this.height = 320.0,
    this.adLoader,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: NativeAdWidget(
        adUnitId: adUnitId,
        request: request,
        factoryId: factoryId,
        adLoader: adLoader,
        loadingBuilder: loadingBuilder ??
            (context) => const Center(child: CircularProgressIndicator()),
        errorBuilder: errorBuilder ??
            (context, error) =>
                Center(child: Text('Failed to load ad: $error')),
        nativeAdBuilder: (context, ad) {
          return AdWidget(ad: ad);
        },
      ),
    );
  }
}
