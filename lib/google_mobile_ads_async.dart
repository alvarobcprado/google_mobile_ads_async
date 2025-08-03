import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_mobile_ads_async/src/ad_loader.dart';

export 'package:google_mobile_ads/google_mobile_ads.dart';

export 'src/ad_cache_manager.dart';
export 'src/ad_load_exception.dart';
export 'src/widgets/ad_builders.dart';
export 'src/widgets/banner_ad_widget.dart';
export 'src/widgets/native_ad_widget.dart';

/// A facade for the Google Mobile Ads SDK that provides a simplified,
/// asynchronous API for loading and managing ads.
class GoogleMobileAdsAsync {
  static final _loader = AsyncAdLoader();

  /// Loads a [BannerAd] asynchronously.
  static Future<BannerAd> loadBannerAd({
    required String adUnitId,
    required AdSize size,
    AdRequest? request,
  }) =>
      _loader.loadBannerAd(adUnitId: adUnitId, size: size, request: request);

  /// Loads an [InterstitialAd] asynchronously.
  static Future<InterstitialAd> loadInterstitialAd({
    required String adUnitId,
    AdRequest? request,
  }) =>
      _loader.loadInterstitialAd(adUnitId: adUnitId, request: request);

  /// Loads a [RewardedAd] asynchronously.
  static Future<RewardedAd> loadRewardedAd({
    required String adUnitId,
    AdRequest? request,
  }) =>
      _loader.loadRewardedAd(adUnitId: adUnitId, request: request);

  /// Loads a [RewardedInterstitialAd] asynchronously.
  static Future<RewardedInterstitialAd> loadRewardedInterstitialAd({
    required String adUnitId,
    AdRequest? request,
  }) =>
      _loader.loadRewardedInterstitialAd(adUnitId: adUnitId, request: request);

  /// Loads a [NativeAd] asynchronously.
  static Future<NativeAd> loadNativeAd({
    required String adUnitId,
    AdRequest? request,
    NativeAdOptions? nativeAdOptions,
    String? factoryId,
  }) =>
      _loader.loadNativeAd(
        adUnitId: adUnitId,
        request: request,
        nativeAdOptions: nativeAdOptions,
        factoryId: factoryId,
      );

  /// Loads an [AppOpenAd] asynchronously.
  static Future<AppOpenAd> loadAppOpenAd({
    required String adUnitId,
    AdRequest? request,
  }) =>
      _loader.loadAppOpenAd(adUnitId: adUnitId, request: request);
}
