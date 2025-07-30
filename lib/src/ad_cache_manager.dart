import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_loader.dart';

/// An enumeration of the different ad types supported by the cache manager.
enum AdType {
  banner,
  interstitial,
  rewarded,
  rewardedInterstitial,
  native,
  appOpen,
}

/// A manager for pre-loading and caching ads to improve performance.
class AdCacheManager {
  AdCacheManager._() : _loader = AsyncAdLoader();

  /// The singleton instance of [AdCacheManager].
  static final instance = AdCacheManager._();

  final AsyncAdLoader _loader;
  final _cache = <String, Ad>{};

  // A constructor for testing that allows injecting a mock AsyncAdLoader.
  @visibleForTesting
  AdCacheManager.withLoader(this._loader);

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
      // Ad already loaded or is loading.
      return;
    }

    try {
      Ad? ad;
      switch (type) {
        case AdType.banner:
          assert(size != null, 'AdSize must be provided for banner ads.');
          ad = await _loader.loadBannerAd(adUnitId: adUnitId, size: size!, request: request);
          break;
        case AdType.interstitial:
          ad = await _loader.loadInterstitialAd(adUnitId: adUnitId, request: request);
          break;
        case AdType.rewarded:
          ad = await _loader.loadRewardedAd(adUnitId: adUnitId, request: request);
          break;
        case AdType.rewardedInterstitial:
          ad = await _loader.loadRewardedInterstitialAd(adUnitId: adUnitId, request: request);
          break;
        case AdType.native:
          ad = await _loader.loadNativeAd(adUnitId: adUnitId, request: request);
          break;
        case AdType.appOpen:
          ad = await _loader.loadAppOpenAd(adUnitId: adUnitId, request: request);
          break;
      }
      if (ad != null) {
        _cache[adUnitId] = ad;
      }
    } catch (e) {
      // Failed to load, ad will not be cached.
      print('Failed to preload ad for $adUnitId: $e');
    }
  }

  /// Retrieves a preloaded ad from the cache.
  ///
  /// Returns the ad if it exists, otherwise returns `null`.
  /// The ad is removed from the cache upon retrieval.
  T? getAd<T extends Ad>(String adUnitId) {
    final ad = _cache.remove(adUnitId);
    if (ad is T) {
      return ad;
    }
    return null;
  }

  /// Disposes of a specific ad in the cache.
  void disposeAd(String adUnitId) {
    _cache.remove(adUnitId)?.dispose();
  }

  /// Disposes of all ads in the cache.
  void disposeAllAds() {
    for (final ad in _cache.values) {
      ad.dispose();
    }
    _cache.clear();
  }
}
