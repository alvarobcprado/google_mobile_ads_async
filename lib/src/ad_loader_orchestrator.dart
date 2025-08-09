import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_mobile_ads_async/src/ad_load_exception.dart';
import 'package:google_mobile_ads_async/src/ad_loader.dart';
import 'package:google_mobile_ads_async/src/ad_waterfall_exception.dart';
import 'package:google_mobile_ads_async/src/utils/logger.dart';

/// Manages the ad loading process, supporting single requests and waterfalls.
class AdLoaderOrchestrator {
  /// The default constructor uses the real AsyncAdLoader.
  AdLoaderOrchestrator() : _adLoader = AsyncAdLoader();

  /// A constructor for testing that allows injecting a mock AsyncAdLoader.
  @visibleForTesting
  AdLoaderOrchestrator.withLoader(this._adLoader);

  final AsyncAdLoader _adLoader;

  /// Loads a banner ad, trying each adUnitId in sequence until one succeeds.
  Future<BannerAd> loadBannerAd({
    required List<String> adUnitIds,
    required AdSize size,
    AdRequest? request,
  }) async {
    assert(adUnitIds.isNotEmpty, 'adUnitIds list cannot be empty.');

    final errors = <AdLoadException>[];
    for (final id in adUnitIds) {
      try {
        final ad = await _adLoader.loadBannerAd(
          adUnitId: id,
          size: size,
          request: request,
        );
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

  /// Loads an interstitial ad, trying each adUnitId in sequence until one
  /// succeeds.
  Future<InterstitialAd> loadInterstitialAd({
    required List<String> adUnitIds,
    AdRequest? request,
  }) async {
    assert(adUnitIds.isNotEmpty, 'adUnitIds list cannot be empty.');

    final errors = <AdLoadException>[];
    for (final id in adUnitIds) {
      try {
        final ad = await _adLoader.loadInterstitialAd(
          adUnitId: id,
          request: request,
        );
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

  // Note: Similar methods for Rewarded, etc., would go here.

  /// Loads a rewarded ad, trying each adUnitId in sequence until one succeeds.
  Future<RewardedAd> loadRewardedAd({
    required List<String> adUnitIds,
    AdRequest? request,
  }) async {
    assert(adUnitIds.isNotEmpty, 'adUnitIds list cannot be empty.');

    final errors = <AdLoadException>[];
    for (final id in adUnitIds) {
      try {
        final ad = await _adLoader.loadRewardedAd(
          adUnitId: id,
          request: request,
        );
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

  /// Loads a rewarded interstitial ad, trying each adUnitId in sequence until
  /// one succeeds.
  Future<RewardedInterstitialAd> loadRewardedInterstitialAd({
    required List<String> adUnitIds,
    AdRequest? request,
  }) async {
    assert(adUnitIds.isNotEmpty, 'adUnitIds list cannot be empty.');

    final errors = <AdLoadException>[];
    for (final id in adUnitIds) {
      try {
        final ad = await _adLoader.loadRewardedInterstitialAd(
          adUnitId: id,
          request: request,
        );
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

  /// Loads a native ad, trying each adUnitId in sequence until one succeeds.
  Future<NativeAd> loadNativeAd({
    required List<String> adUnitIds,
    AdRequest? request,
    NativeAdOptions? nativeAdOptions,
    String? factoryId,
  }) async {
    assert(adUnitIds.isNotEmpty, 'adUnitIds list cannot be empty.');

    final errors = <AdLoadException>[];
    for (final id in adUnitIds) {
      try {
        final ad = await _adLoader.loadNativeAd(
          adUnitId: id,
          request: request,
          nativeAdOptions: nativeAdOptions,
          factoryId: factoryId,
        );
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

  /// Loads an app open ad, trying each adUnitId in sequence until one succeeds.
  Future<AppOpenAd> loadAppOpenAd({
    required List<String> adUnitIds,
    AdRequest? request,
  }) async {
    assert(adUnitIds.isNotEmpty, 'adUnitIds list cannot be empty.');

    final errors = <AdLoadException>[];
    for (final id in adUnitIds) {
      try {
        final ad = await _adLoader.loadAppOpenAd(
          adUnitId: id,
          request: request,
        );
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
}
