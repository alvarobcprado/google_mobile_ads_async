import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_mobile_ads_async/src/ad_factory.dart';
import 'package:google_mobile_ads_async/src/ad_load_exception.dart';
import 'package:google_mobile_ads_async/src/utils/logger.dart';

/// A utility class to load various ad formats using a Future-based API.
class AsyncAdLoader {
  /// The default constructor uses the real AdFactory.
  AsyncAdLoader() : _adFactory = AdFactory();

  /// A constructor for testing that allows injecting a mock AdFactory.
  AsyncAdLoader.withFactory(this._adFactory);
  final AdFactory _adFactory;

  /// Loads a [BannerAd].
  Future<BannerAd> loadBannerAd({
    required String adUnitId,
    required AdSize size,
    AdRequest? request,
  }) {
    AdLogger.debug('Attempting to load BannerAd with AdUnitId: $adUnitId');
    final completer = Completer<BannerAd>();
    _adFactory.loadBannerAd(
      adUnitId,
      size,
      request ?? const AdRequest(),
      BannerAdListener(
        onAdLoaded: (ad) {
          AdLogger.info('BannerAd loaded successfully. AdUnitId: $adUnitId');
          completer.complete(ad as BannerAd);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          AdLogger.error(
            'Failed to load BannerAd. AdUnitId: $adUnitId',
            error: error,
          );
          completer.completeError(AdLoadException(error));
        },
      ),
    );
    return completer.future;
  }

  /// Loads an [InterstitialAd].
  Future<InterstitialAd> loadInterstitialAd({
    required String adUnitId,
    AdRequest? request,
  }) {
    AdLogger.debug(
      'Attempting to load InterstitialAd with AdUnitId: $adUnitId',
    );
    final completer = Completer<InterstitialAd>();
    _adFactory.loadInterstitialAd(
      adUnitId,
      request ?? const AdRequest(),
      InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          AdLogger.info(
            'InterstitialAd loaded successfully. AdUnitId: $adUnitId',
          );
          completer.complete(ad);
        },
        onAdFailedToLoad: (error) {
          AdLogger.error(
            'Failed to load InterstitialAd. AdUnitId: $adUnitId',
            error: error,
          );
          completer.completeError(AdLoadException(error));
        },
      ),
    );
    return completer.future;
  }

  /// Loads a [RewardedAd].
  Future<RewardedAd> loadRewardedAd({
    required String adUnitId,
    AdRequest? request,
  }) {
    AdLogger.debug('Attempting to load RewardedAd with AdUnitId: $adUnitId');
    final completer = Completer<RewardedAd>();
    _adFactory.loadRewardedAd(
      adUnitId,
      request ?? const AdRequest(),
      RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          AdLogger.info('RewardedAd loaded successfully. AdUnitId: $adUnitId');
          completer.complete(ad);
        },
        onAdFailedToLoad: (error) {
          AdLogger.error(
            'Failed to load RewardedAd. AdUnitId: $adUnitId',
            error: error,
          );
          completer.completeError(AdLoadException(error));
        },
      ),
    );
    return completer.future;
  }

  /// Loads a [RewardedInterstitialAd].
  Future<RewardedInterstitialAd> loadRewardedInterstitialAd({
    required String adUnitId,
    AdRequest? request,
  }) {
    AdLogger.debug(
      'Attempting to load RewardedInterstitialAd with AdUnitId: $adUnitId',
    );
    final completer = Completer<RewardedInterstitialAd>();
    _adFactory.loadRewardedInterstitialAd(
      adUnitId,
      request ?? const AdRequest(),
      RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          AdLogger.info(
            'RewardedInterstitialAd loaded successfully. AdUnitId: $adUnitId',
          );
          completer.complete(ad);
        },
        onAdFailedToLoad: (error) {
          AdLogger.error(
            'Failed to load RewardedInterstitialAd. AdUnitId: $adUnitId',
            error: error,
          );
          completer.completeError(AdLoadException(error));
        },
      ),
    );
    return completer.future;
  }

  /// Loads a [NativeAd].
  Future<NativeAd> loadNativeAd({
    required String adUnitId,
    AdRequest? request,
    NativeAdOptions? nativeAdOptions,
    String? factoryId,
    NativeTemplateStyle? nativeTemplateStyle,
  }) {
    AdLogger.debug('Attempting to load NativeAd with AdUnitId: $adUnitId');
    final completer = Completer<NativeAd>();
    _adFactory.loadNativeAd(
      adUnitId,
      request ?? const AdRequest(),
      nativeAdOptions,
      factoryId,
      NativeAdListener(
        onAdLoaded: (ad) {
          AdLogger.info('NativeAd loaded successfully. AdUnitId: $adUnitId');
          completer.complete(ad as NativeAd);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          AdLogger.error(
            'Failed to load NativeAd. AdUnitId: $adUnitId',
            error: error,
          );
          completer.completeError(AdLoadException(error));
        },
      ),
      nativeTemplateStyle,
    );
    return completer.future;
  }

  /// Loads an [AppOpenAd].
  Future<AppOpenAd> loadAppOpenAd({
    required String adUnitId,
    AdRequest? request,
  }) {
    AdLogger.debug('Attempting to load AppOpenAd with AdUnitId: $adUnitId');
    final completer = Completer<AppOpenAd>();
    _adFactory.loadAppOpenAd(
      adUnitId,
      request ?? const AdRequest(),
      AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          AdLogger.info('AppOpenAd loaded successfully. AdUnitId: $adUnitId');
          completer.complete(ad);
        },
        onAdFailedToLoad: (error) {
          AdLogger.error(
            'Failed to load AppOpenAd. AdUnitId: $adUnitId',
            error: error,
          );
          completer.completeError(AdLoadException(error));
        },
      ),
    );
    return completer.future;
  }
}
