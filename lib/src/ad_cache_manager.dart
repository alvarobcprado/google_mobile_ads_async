import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_mobile_ads_async/src/ad_loader_orchestrator.dart';
import 'package:google_mobile_ads_async/src/ad_waterfall_exception.dart';
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
///
/// This manager supports ad waterfalls by accepting a list of ad unit IDs.
class AdCacheManager {
  AdCacheManager._() : _orchestrator = AdLoaderOrchestrator();

  /// A constructor for testing that allows injecting a mock
  /// AdLoaderOrchestrator.
  @visibleForTesting
  AdCacheManager.withOrchestrator(this._orchestrator);

  /// The singleton instance of [AdCacheManager].
  static final instance = AdCacheManager._();

  final AdLoaderOrchestrator _orchestrator;
  final _cache = <String, Ad>{};

  /// Creates a unique key for a given list of ad unit IDs.
  String _getCacheKey(List<String> adUnitIds) => adUnitIds.join(',');

  /// Preloads an ad and stores it in the cache.
  ///
  /// - [adUnitIds]: A list of ad unit IDs to be tried in a waterfall sequence.
  /// - [type]: The type of ad to load.
  /// - [size]: The size of the banner ad (required for banner ads).
  /// - [request]: The ad request.
  Future<void> preloadAd({
    required List<String> adUnitIds,
    required AdType type,
    AdSize? size,
    AdRequest? request,
  }) async {
    final cacheKey = _getCacheKey(adUnitIds);
    if (_cache.containsKey(cacheKey)) {
      AdLogger.debug(
        'Ad for AdUnitIds: $adUnitIds already loaded or is loading.',
      );
      return;
    }

    AdLogger.debug('Preloading ad for AdUnitIds: $adUnitIds');

    try {
      final Ad ad;
      switch (type) {
        case AdType.banner:
          assert(size != null, 'AdSize must be provided for banner ads.');
          ad = await _orchestrator.loadBannerAd(
            adUnitIds: adUnitIds,
            size: size!,
            request: request,
          );
        case AdType.interstitial:
          ad = await _orchestrator.loadInterstitialAd(
            adUnitIds: adUnitIds,
            request: request,
          );
        case AdType.rewarded:
          ad = await _orchestrator.loadRewardedAd(
            adUnitIds: adUnitIds,
            request: request,
          );
        case AdType.rewardedInterstitial:
          ad = await _orchestrator.loadRewardedInterstitialAd(
            adUnitIds: adUnitIds,
            request: request,
          );
        case AdType.native:
          ad = await _orchestrator.loadNativeAd(
            adUnitIds: adUnitIds,
            request: request,
          );
        case AdType.appOpen:
          ad = await _orchestrator.loadAppOpenAd(
            adUnitIds: adUnitIds,
            request: request,
          );
      }
      _cache[cacheKey] = ad;
      AdLogger.info('Successfully preloaded ad for AdUnitIds: $adUnitIds');
    } on AdWaterfallException catch (e) {
      AdLogger.error('Failed to preload ad for $adUnitIds', error: e);
    }
  }

  /// Retrieves a preloaded ad from the cache.
  ///
  /// Returns the ad if it exists, otherwise returns `null`.
  /// The ad is removed from the cache upon retrieval.
  T? getAd<T extends Ad>(List<String> adUnitIds) {
    final cacheKey = _getCacheKey(adUnitIds);
    final ad = _cache.remove(cacheKey);
    AdLogger.debug(
      'Retrieving ad from cache for AdUnitIds: $adUnitIds. '
      'Found: ${ad != null}',
    );
    if (ad is T) {
      return ad;
    }
    return null;
  }

  /// Disposes of a specific ad in the cache.
  void disposeAd(List<String> adUnitIds) {
    final cacheKey = _getCacheKey(adUnitIds);
    AdLogger.debug('Disposing ad from cache for AdUnitIds: $adUnitIds');
    _cache.remove(cacheKey)?.dispose();
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
