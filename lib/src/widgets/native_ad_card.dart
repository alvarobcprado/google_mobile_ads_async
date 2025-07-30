import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class NativeAdCard extends StatelessWidget {
  final NativeAd nativeAd;

  const NativeAdCard({super.key, required this.nativeAd});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: AdWidget(ad: nativeAd),
    );
  }
}
