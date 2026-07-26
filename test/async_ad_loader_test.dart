import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_mobile_ads_async/src/ad_factory.dart';
import 'package:google_mobile_ads_async/src/ad_load_exception.dart';
import 'package:google_mobile_ads_async/src/async_ad_loader.dart';
import 'package:mocktail/mocktail.dart';

class CapturingAdFactory extends AdFactory {
  late BannerAdListener bannerListener;
  late InterstitialAdLoadCallback interstitialCallback;
  late RewardedAdLoadCallback rewardedCallback;
  late RewardedInterstitialAdLoadCallback rewardedInterstitialCallback;
  late NativeAdListener nativeListener;
  late AppOpenAdLoadCallback appOpenCallback;

  @override
  void loadBannerAd(
    String adUnitId,
    AdSize size,
    AdRequest request,
    BannerAdListener listener,
  ) {
    bannerListener = listener;
  }

  @override
  void loadInterstitialAd(
    String adUnitId,
    AdRequest request,
    InterstitialAdLoadCallback adLoadCallback,
  ) {
    interstitialCallback = adLoadCallback;
  }

  @override
  void loadRewardedAd(
    String adUnitId,
    AdRequest request,
    RewardedAdLoadCallback rewardedAdLoadCallback,
  ) {
    rewardedCallback = rewardedAdLoadCallback;
  }

  @override
  void loadRewardedInterstitialAd(
    String adUnitId,
    AdRequest request,
    RewardedInterstitialAdLoadCallback rewardedInterstitialAdLoadCallback,
  ) {
    rewardedInterstitialCallback = rewardedInterstitialAdLoadCallback;
  }

  @override
  void loadNativeAd(
    String adUnitId,
    AdRequest request,
    NativeAdOptions? nativeAdOptions,
    String? factoryId,
    NativeAdListener listener,
    NativeTemplateStyle? nativeTemplateStyle,
  ) {
    nativeListener = listener;
  }

  @override
  void loadAppOpenAd(
    String adUnitId,
    AdRequest request,
    AppOpenAdLoadCallback adLoadCallback,
  ) {
    appOpenCallback = adLoadCallback;
  }
}

class MockBannerAd extends Mock implements BannerAd {}

class MockInterstitialAd extends Mock implements InterstitialAd {}

class MockRewardedAd extends Mock implements RewardedAd {}

class MockRewardedInterstitialAd extends Mock
    implements RewardedInterstitialAd {}

class MockNativeAd extends Mock implements NativeAd {}

class MockAppOpenAd extends Mock implements AppOpenAd {}

class MockLoadAdError extends Mock implements LoadAdError {}

void main() {
  late CapturingAdFactory factory;
  late AsyncAdLoader loader;
  late MockLoadAdError error;

  setUp(() {
    factory = CapturingAdFactory();
    loader = AsyncAdLoader.withFactory(factory);
    error = MockLoadAdError();
  });

  test('loads a banner and ignores a duplicate success callback', () async {
    final firstAd = MockBannerAd();
    final duplicateAd = MockBannerAd();
    final future = loader.loadBannerAd(
      adUnitId: 'banner',
      size: AdSize.banner,
    );

    factory.bannerListener.onAdLoaded?.call(firstAd);
    factory.bannerListener.onAdLoaded?.call(duplicateAd);

    expect(await future, same(firstAd));
  });

  test('disposes a banner and wraps its load error', () async {
    final ad = MockBannerAd();
    when(ad.dispose).thenAnswer((_) async {});
    final future = loader.loadBannerAd(
      adUnitId: 'banner',
      size: AdSize.banner,
    );
    final expectation = expectLater(future, throwsA(isA<AdLoadException>()));

    factory.bannerListener.onAdFailedToLoad?.call(ad, error);

    await expectation;
    verify(ad.dispose).called(1);
  });

  test('loads an interstitial', () async {
    final ad = MockInterstitialAd();
    final future = loader.loadInterstitialAd(adUnitId: 'interstitial');

    factory.interstitialCallback.onAdLoaded(ad);

    expect(await future, same(ad));
  });

  test('wraps an interstitial load error', () async {
    final future = loader.loadInterstitialAd(adUnitId: 'interstitial');
    final expectation = expectLater(future, throwsA(isA<AdLoadException>()));

    factory.interstitialCallback.onAdFailedToLoad(error);

    await expectation;
  });

  test('loads a rewarded ad', () async {
    final ad = MockRewardedAd();
    final future = loader.loadRewardedAd(adUnitId: 'rewarded');

    factory.rewardedCallback.onAdLoaded(ad);

    expect(await future, same(ad));
  });

  test('wraps a rewarded load error', () async {
    final future = loader.loadRewardedAd(adUnitId: 'rewarded');
    final expectation = expectLater(future, throwsA(isA<AdLoadException>()));

    factory.rewardedCallback.onAdFailedToLoad(error);

    await expectation;
  });

  test('loads a rewarded interstitial ad', () async {
    final ad = MockRewardedInterstitialAd();
    final future = loader.loadRewardedInterstitialAd(
      adUnitId: 'rewarded-interstitial',
    );

    factory.rewardedInterstitialCallback.onAdLoaded(ad);

    expect(await future, same(ad));
  });

  test('wraps a rewarded interstitial load error', () async {
    final future = loader.loadRewardedInterstitialAd(
      adUnitId: 'rewarded-interstitial',
    );
    final expectation = expectLater(future, throwsA(isA<AdLoadException>()));

    factory.rewardedInterstitialCallback.onAdFailedToLoad(error);

    await expectation;
  });

  test('loads a native ad', () async {
    final ad = MockNativeAd();
    final future = loader.loadNativeAd(adUnitId: 'native');

    factory.nativeListener.onAdLoaded?.call(ad);

    expect(await future, same(ad));
  });

  test('disposes a native ad and wraps its load error', () async {
    final ad = MockNativeAd();
    when(ad.dispose).thenAnswer((_) async {});
    final future = loader.loadNativeAd(adUnitId: 'native');
    final expectation = expectLater(future, throwsA(isA<AdLoadException>()));

    factory.nativeListener.onAdFailedToLoad?.call(ad, error);

    await expectation;
    verify(ad.dispose).called(1);
  });

  test('loads an app open ad', () async {
    final ad = MockAppOpenAd();
    final future = loader.loadAppOpenAd(adUnitId: 'app-open');

    factory.appOpenCallback.onAdLoaded(ad);

    expect(await future, same(ad));
  });

  test('wraps an app open load error', () async {
    final future = loader.loadAppOpenAd(adUnitId: 'app-open');
    final expectation = expectLater(future, throwsA(isA<AdLoadException>()));

    factory.appOpenCallback.onAdFailedToLoad(error);

    await expectation;
  });
}
