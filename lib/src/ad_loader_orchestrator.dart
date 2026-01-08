import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads_async/google_mobile_ads_async.dart';
import 'package:google_mobile_ads_async/src/async_ad_loader.dart';
import 'package:google_mobile_ads_async/src/utils/logger.dart';

/// Manages the ad loading process, supporting single requests and waterfalls.
class AdLoaderOrchestrator {
  /// The default constructor uses the real AsyncAdLoader.
  AdLoaderOrchestrator() : _adLoader = AsyncAdLoader();

  /// A constructor for testing that allows injecting a mock AsyncAdLoader.
  @visibleForTesting
  AdLoaderOrchestrator.withLoader(this._adLoader);

  final AsyncAdLoader _adLoader;

  /// A generic method to handle the waterfall loading logic for any ad type.
  Future<T> _loadAdWithWaterfall<T extends Ad>({
    required List<String> adUnitIds,
    required Future<T> Function(String adUnitId) loadFunction,
  }) async {
    if (!GoogleMobileAdsAsync.isAdsEnabled) {
      AdLogger.warning('Ad loading is globally disabled. Throwing exception.');
      return Future.error(
        AdLoadException(
          LoadAdError(
            -1,
            'GLOBALLY_DISABLED',
            'Ad loading is globally disabled',
            null,
          ),
        ),
      );
    }
    assert(adUnitIds.isNotEmpty, 'adUnitIds list cannot be empty.');

    final errors = <AdLoadException>[];
    for (final id in adUnitIds) {
      try {
        final ad = await loadFunction(id);
        AdLogger.info('Waterfall: Successfully loaded ad for $id.');
        return ad;
      } on AdLoadException catch (e) {
        errors.add(e);
        AdLogger.warning(
          'Waterfall: Failed to load ad for $id. Trying next...',
        );
      }
    }

    AdLogger.error('Waterfall: All ad unit IDs failed to load.');
    throw AdWaterfallException(errors);
  }

  /// Loads a banner ad, trying each adUnitId in sequence until one succeeds.
  Future<BannerAd> loadBannerAd({
    required List<String> adUnitIds,
    required AdSize size,
    AdRequest? request,
  }) async {
    return _loadAdWithWaterfall(
      adUnitIds: adUnitIds,
      loadFunction: (adUnitId) => _adLoader.loadBannerAd(
        adUnitId: adUnitId,
        size: size,
        request: request,
      ),
    );
  }

  /// Loads an interstitial ad, trying each adUnitId in sequence until one
  /// succeeds.
  Future<InterstitialAd> loadInterstitialAd({
    required List<String> adUnitIds,
    AdRequest? request,
  }) async {
    return _loadAdWithWaterfall(
      adUnitIds: adUnitIds,
      loadFunction: (adUnitId) => _adLoader.loadInterstitialAd(
        adUnitId: adUnitId,
        request: request,
      ),
    );
  }

  /// Loads a rewarded ad, trying each adUnitId in sequence until one succeeds.
  Future<RewardedAd> loadRewardedAd({
    required List<String> adUnitIds,
    AdRequest? request,
  }) async {
    return _loadAdWithWaterfall(
      adUnitIds: adUnitIds,
      loadFunction: (adUnitId) => _adLoader.loadRewardedAd(
        adUnitId: adUnitId,
        request: request,
      ),
    );
  }

  /// Loads a rewarded interstitial ad, trying each adUnitId in sequence until
  /// one succeeds.
  Future<RewardedInterstitialAd> loadRewardedInterstitialAd({
    required List<String> adUnitIds,
    AdRequest? request,
  }) async {
    return _loadAdWithWaterfall(
      adUnitIds: adUnitIds,
      loadFunction: (adUnitId) => _adLoader.loadRewardedInterstitialAd(
        adUnitId: adUnitId,
        request: request,
      ),
    );
  }

  /// Loads a native ad, trying each adUnitId in sequence until one succeeds.
  Future<NativeAd> loadNativeAd({
    required List<String> adUnitIds,
    AdRequest? request,
    NativeAdOptions? nativeAdOptions,
    String? factoryId,
    NativeTemplateStyle? nativeTemplateStyle,
  }) async {
    return _loadAdWithWaterfall(
      adUnitIds: adUnitIds,
      loadFunction: (adUnitId) => _adLoader.loadNativeAd(
        adUnitId: adUnitId,
        request: request,
        nativeAdOptions: nativeAdOptions,
        factoryId: factoryId,
        nativeTemplateStyle: nativeTemplateStyle,
      ),
    );
  }

  /// Loads an app open ad, trying each adUnitId in sequence until one succeeds.
  Future<AppOpenAd> loadAppOpenAd({
    required List<String> adUnitIds,
    AdRequest? request,
  }) async {
    return _loadAdWithWaterfall(
      adUnitIds: adUnitIds,
      loadFunction: (adUnitId) => _adLoader.loadAppOpenAd(
        adUnitId: adUnitId,
        request: request,
      ),
    );
  }
}
