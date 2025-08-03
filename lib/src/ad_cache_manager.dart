import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_mobile_ads_async/google_mobile_ads_async.dart'
    show AdLoadException;
import 'package:google_mobile_ads_async/src/ad_loader.dart';
import 'package:google_mobile_ads_async/src/utils/logger.dart';

/// An enumeration of the different ad types supported by the cache manager.
enum AdType {
  /// Banner ad type
  banner,

  /// Interstitial ad type
  interstitial,

  /// Rewarded ad type
  rewarded,

  /// Rewarded interstitial ad type
  rewardedInterstitial,

  /// Native ad type
  native,

  /// App open ad type
  appOpen,
}

/// A manager for pre-loading and caching ads to improve performance.
class AdCacheManager {
  AdCacheManager._() : _loader = AsyncAdLoader();

  /// A constructor for testing that allows injecting a mock AsyncAdLoader.
  @visibleForTesting
  AdCacheManager.withLoader(this._loader);

  /// The singleton instance of [AdCacheManager].
  static final instance = AdCacheManager._();

  final AsyncAdLoader _loader;
  final _cache = <String, Ad>{};

  /// Preloads an ad and stores it in the cache.
  ///
  /// - [adUnitId]: The ad unit ID to load.
  /// - [type]: The type of ad to load.
  /// - [size]: The size of the banner ad (required for banner ads).
  /// - [request]: The ad request.
  Future<void> preloadAd(
    String adUnitId,
    AdType type, {
    AdSize? size,
    AdRequest? request,
  }) async {
    if (_cache.containsKey(adUnitId)) {
      AdLogger.debug(
        'Ad for AdUnitId: $adUnitId already loaded or is loading.',
      );
      return;
    }

    AdLogger.debug('Preloading ad for AdUnitId: $adUnitId');

    try {
      final Ad ad;
      switch (type) {
        case AdType.banner:
          assert(size != null, 'AdSize must be provided for banner ads.');
          ad = await _loader.loadBannerAd(
            adUnitId: adUnitId,
            size: size!,
            request: request,
          );
        case AdType.interstitial:
          ad = await _loader.loadInterstitialAd(
            adUnitId: adUnitId,
            request: request,
          );
        case AdType.rewarded:
          ad = await _loader.loadRewardedAd(
            adUnitId: adUnitId,
            request: request,
          );
        case AdType.rewardedInterstitial:
          ad = await _loader.loadRewardedInterstitialAd(
            adUnitId: adUnitId,
            request: request,
          );
        case AdType.native:
          ad = await _loader.loadNativeAd(
            adUnitId: adUnitId,
            request: request,
          );
        case AdType.appOpen:
          ad = await _loader.loadAppOpenAd(
            adUnitId: adUnitId,
            request: request,
          );
      }
      _cache[adUnitId] = ad;
      AdLogger.info('Successfully preloaded ad for AdUnitId: $adUnitId');
    } on AdLoadException catch (e) {
      AdLogger.error('Failed to preload ad for $adUnitId', error: e);
    }
  }

  /// Retrieves a preloaded ad from the cache.
  ///
  /// Returns the ad if it exists, otherwise returns `null`.
  /// The ad is removed from the cache upon retrieval.
  T? getAd<T extends Ad>(String adUnitId) {
    final ad = _cache.remove(adUnitId);
    AdLogger.debug(
      'Retrieving ad from cache for AdUnitId: $adUnitId. Found: ${ad != null}',
    );
    if (ad is T) {
      return ad;
    }
    return null;
  }

  /// Disposes of a specific ad in the cache.
  void disposeAd(String adUnitId) {
    AdLogger.debug('Disposing ad from cache for AdUnitId: $adUnitId');
    _cache.remove(adUnitId)?.dispose();
  }

  /// Disposes of all ads in the cache.
  void disposeAllAds() {
    AdLogger.info('Disposing all cached ads.');
    for (final ad in _cache.values) {
      ad.dispose();
    }
    _cache.clear();
  }
}
