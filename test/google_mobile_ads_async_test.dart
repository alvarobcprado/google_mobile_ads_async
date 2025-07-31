import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads_async/google_mobile_ads_async.dart';
import 'package:google_mobile_ads_async/src/ad_loader.dart';
import 'package:mocktail/mocktail.dart';

// --- Mock Classes using Mocktail ---

class MockAsyncAdLoader extends Mock implements AsyncAdLoader {}

class MockBannerAd extends Mock implements BannerAd {}

class MockInterstitialAd extends Mock implements InterstitialAd {}

class MockRewardedAd extends Mock implements RewardedAd {}

class MockLoadAdError extends Mock implements LoadAdError {}

void main() {
  // Register a fallback value for AdRequest, required by mocktail.
  setUpAll(() {
    registerFallbackValue(const AdRequest());
  });

  group('AdCacheManager with Mocktail', () {
    late MockAsyncAdLoader mockAdLoader;
    late AdCacheManager cacheManager;

    setUp(() {
      mockAdLoader = MockAsyncAdLoader();
      cacheManager = AdCacheManager.withLoader(mockAdLoader);
    });

    tearDown(() {
      cacheManager.disposeAllAds();
    });

    test('preloadAd successfully caches an ad', () async {
      final mockAd = MockBannerAd();
      // Use the function-based `when` from mocktail.
      when(
        () => mockAdLoader.loadBannerAd(
          adUnitId: 'test-banner',
          size: AdSize.banner,
          request: any(named: 'request'),
        ),
      ).thenAnswer((_) async => mockAd);

      await cacheManager.preloadAd(
        'test-banner',
        AdType.banner,
        size: AdSize.banner,
      );

      final cachedAd = cacheManager.getAd<BannerAd>('test-banner');
      expect(cachedAd, equals(mockAd));
    });

    test('preloadAd does not cache an ad on failure', () async {
      final mockError = MockLoadAdError();
      when(() => mockError.message).thenReturn('Failed to load');
      when(() => mockError.code).thenReturn(1);
      when(
        () => mockAdLoader.loadBannerAd(
          adUnitId: 'test-banner-fail',
          size: AdSize.banner,
          request: any(named: 'request'),
        ),
      ).thenThrow(AdLoadException(mockError));

      // No need to `await` here since we are just checking the side effect.
      await cacheManager.preloadAd(
        'test-banner-fail',
        AdType.banner,
        size: AdSize.banner,
      );

      final cachedAd = cacheManager.getAd<BannerAd>('test-banner-fail');
      expect(cachedAd, isNull);
    });

    test('getAd returns null for wrong ad type', () async {
      final mockAd = MockBannerAd();
      when(
        () => mockAdLoader.loadBannerAd(
          adUnitId: 'test-banner',
          size: AdSize.banner,
          request: any(named: 'request'),
        ),
      ).thenAnswer((_) async => mockAd);

      await cacheManager.preloadAd(
        'test-banner',
        AdType.banner,
        size: AdSize.banner,
      );

      final cachedAd = cacheManager.getAd<InterstitialAd>('test-banner');
      expect(cachedAd, isNull);
    });

    test('disposeAd removes and disposes the ad', () async {
      final mockAd = MockBannerAd();
      when(mockAd.dispose).thenAnswer((_) async {});
      when(
        () => mockAdLoader.loadBannerAd(
          adUnitId: 'test-banner',
          size: AdSize.banner,
          request: any(named: 'request'),
        ),
      ).thenAnswer((_) async => mockAd);

      await cacheManager.preloadAd(
        'test-banner',
        AdType.banner,
        size: AdSize.banner,
      );

      cacheManager.disposeAd('test-banner');
      verify(mockAd.dispose).called(1);
      final cachedAd = cacheManager.getAd<BannerAd>('test-banner');
      expect(cachedAd, isNull);
    });
  });
}
