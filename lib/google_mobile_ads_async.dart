import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_mobile_ads_async/src/ad_loader_orchestrator.dart';
import 'package:google_mobile_ads_async/src/utils/logger.dart';
import 'package:logger/logger.dart' show Level;

export 'package:google_mobile_ads/google_mobile_ads.dart';
export 'package:logger/logger.dart' show Level;

export 'src/ad_cache_manager.dart';
export 'src/ad_load_exception.dart';
export 'src/ad_waterfall_exception.dart';
export 'src/widgets/ad_builders.dart';
export 'src/widgets/banner_ad_widget.dart';
export 'src/widgets/native_ad_widget.dart';

/// A facade for the Google Mobile Ads SDK that provides a simplified,
/// asynchronous API for loading and managing ads.
class GoogleMobileAdsAsync {
  static final _orchestrator = AdLoaderOrchestrator();

  /// Sets the log level for the package's internal logger.
  ///
  /// This is useful for debugging ad loading and widget lifecycle issues.
  /// Example: `GoogleMobileAdsAsync.setLogLevel(Level.debug);`
  static void setLogLevel(Level level) {
    AdLogger.setLevel(level);
  }

  /// Loads a [BannerAd] asynchronously.
  ///
  /// Provide a list of [adUnitIds] to be tried in a waterfall sequence.
  /// To load a single ad, provide a list with one ID.
  static Future<BannerAd> loadBannerAd({
    required List<String> adUnitIds,
    required AdSize size,
    AdRequest? request,
  }) =>
      _orchestrator.loadBannerAd(
        adUnitIds: adUnitIds,
        size: size,
        request: request,
      );

  /// Loads an [InterstitialAd] asynchronously.
  ///
  /// Provide a list of [adUnitIds] to be tried in a waterfall sequence.
  /// To load a single ad, provide a list with one ID.
  static Future<InterstitialAd> loadInterstitialAd({
    required List<String> adUnitIds,
    AdRequest? request,
  }) =>
      _orchestrator.loadInterstitialAd(
        adUnitIds: adUnitIds,
        request: request,
      );

  /// Loads a [RewardedAd] asynchronously.
  ///
  /// Provide a list of [adUnitIds] to be tried in a waterfall sequence.
  /// To load a single ad, provide a list with one ID.
  static Future<RewardedAd> loadRewardedAd({
    required List<String> adUnitIds,
    AdRequest? request,
  }) =>
      _orchestrator.loadRewardedAd(
        adUnitIds: adUnitIds,
        request: request,
      );

  /// Loads a [RewardedInterstitialAd] asynchronously.
  ///
  /// Provide a list of [adUnitIds] to be tried in a waterfall sequence.
  /// To load a single ad, provide a list with one ID.
  static Future<RewardedInterstitialAd> loadRewardedInterstitialAd({
    required List<String> adUnitIds,
    AdRequest? request,
  }) =>
      _orchestrator.loadRewardedInterstitialAd(
        adUnitIds: adUnitIds,
        request: request,
      );

  /// Loads a [NativeAd] asynchronously.
  ///
  /// Provide a list of [adUnitIds] to be tried in a waterfall sequence.
  /// To load a single ad, provide a list with one ID.
  static Future<NativeAd> loadNativeAd({
    required List<String> adUnitIds,
    AdRequest? request,
    NativeAdOptions? nativeAdOptions,
    String? factoryId,
  }) =>
      _orchestrator.loadNativeAd(
        adUnitIds: adUnitIds,
        request: request,
        nativeAdOptions: nativeAdOptions,
        factoryId: factoryId,
      );

  /// Loads an [AppOpenAd] asynchronously.
  ///
  /// Provide a list of [adUnitIds] to be tried in a waterfall sequence.
  /// To load a single ad, provide a list with one ID.
  static Future<AppOpenAd> loadAppOpenAd({
    required List<String> adUnitIds,
    AdRequest? request,
  }) =>
      _orchestrator.loadAppOpenAd(
        adUnitIds: adUnitIds,
        request: request,
      );
}
