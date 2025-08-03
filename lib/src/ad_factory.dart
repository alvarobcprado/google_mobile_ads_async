import 'package:google_mobile_ads/google_mobile_ads.dart';

/// A factory class that creates and loads ads.
///
/// This class exists to wrap the static methods of the google_mobile_ads
/// plugin, making them mockable for tests.
class AdFactory {
  /// Loads a [BannerAd].
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

  /// Loads an [InterstitialAd].
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

  /// Loads a [RewardedAd].
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

  /// Loads a [RewardedInterstitialAd].
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

  /// Loads a [NativeAd].
  void loadNativeAd(
    String adUnitId,
    AdRequest request,
    NativeAdOptions? nativeAdOptions,
    String? factoryId,
    NativeAdListener listener,
    NativeTemplateStyle? nativeTemplateStyle,
  ) {
    NativeAd(
      adUnitId: adUnitId,
      request: request,
      nativeAdOptions: nativeAdOptions,
      factoryId: factoryId,
      listener: listener,
      nativeTemplateStyle: factoryId != null
          ? null
          : nativeTemplateStyle ??
              NativeTemplateStyle(templateType: TemplateType.medium),
    ).load();
  }

  /// Loads an [AppOpenAd].
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
