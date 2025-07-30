import 'package:google_mobile_ads/google_mobile_ads.dart';

/// A factory class that creates and loads ads. This class exists to wrap the
/// static methods of the google_mobile_ads plugin, making them mockable for tests.
class AdFactory {
  void loadBannerAd(
    String adUnitId,
    AdSize size,
    AdRequest request,
    BannerAdListener listener,
  ) {
    BannerAd(
      adUnitId: adUnitId,
      size: size,
      request: request,
      listener: listener,
    ).load();
  }

  void loadInterstitialAd(
    String adUnitId,
    AdRequest request,
    InterstitialAdLoadCallback adLoadCallback,
  ) {
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: request,
      adLoadCallback: adLoadCallback,
    );
  }

  void loadRewardedAd(
    String adUnitId,
    AdRequest request,
    RewardedAdLoadCallback rewardedAdLoadCallback,
  ) {
    RewardedAd.load(
      adUnitId: adUnitId,
      request: request,
      rewardedAdLoadCallback: rewardedAdLoadCallback,
    );
  }

  void loadRewardedInterstitialAd(
    String adUnitId,
    AdRequest request,
    RewardedInterstitialAdLoadCallback rewardedInterstitialAdLoadCallback,
  ) {
    RewardedInterstitialAd.load(
      adUnitId: adUnitId,
      request: request,
      rewardedInterstitialAdLoadCallback: rewardedInterstitialAdLoadCallback,
    );
  }

  void loadNativeAd(
    String adUnitId,
    AdRequest request,
    NativeAdOptions? nativeAdOptions,
    String? factoryId,
    NativeAdListener listener,
  ) {
    NativeAd(
      adUnitId: adUnitId,
      request: request,
      nativeAdOptions: nativeAdOptions,
      factoryId: factoryId,
      listener: listener,
    ).load();
  }

  void loadAppOpenAd(
    String adUnitId,
    AdRequest request,
    AppOpenAdLoadCallback adLoadCallback,
  ) {
    AppOpenAd.load(
      adUnitId: adUnitId,
      request: request,
      adLoadCallback: adLoadCallback,
    );
  }
}
